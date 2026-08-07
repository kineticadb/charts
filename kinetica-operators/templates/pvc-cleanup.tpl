{{- with .Values.pvcCleanup }}
{{- if .enabled }}
# One-shot deletion of explicitly named PVCs before a fresh install.
# Use case: STS-created PVCs survive uninstall by design; on a reinstall with
# the same cluster name the StatefulSet rebinds them and boots on stale data.
# Runs as a pre-install hook ONLY (never pre-upgrade — deleting in-use PVCs
# mid-upgrade would hang on the pvc-protection finalizer and time the hook out).
# Same SA/Role/RoleBinding-per-hook pattern as persist-pvc-resize.tpl: the
# helm-chart-operator SA has ["*"] verbs on pvcs/roles/rolebindings/
# serviceaccounts in the managed namespace per rubix-rbac.yaml.
#
# Deliberately requires an explicit PVC name list — no derivation from the
# cluster name. Deleting data volumes should never happen implicitly.
#
#   pvcCleanup:
#     enabled: true
#     # namespace: gpudb            # optional; defaults to kineticacluster.namespace
#     pvcNames:
#       - kinetica-apollo-entity-persist-gpudb-0
#       - workbench-pvc
{{- $ns := .namespace | default $.Values.kineticacluster.namespace | default "gpudb" -}}
{{- if not .pvcNames -}}
  {{- fail "pvcCleanup is enabled but pvcNames is empty — list the PVCs to delete explicitly." -}}
{{- end -}}
{{- $pvcs := .pvcNames -}}
{{- $img := include "kinetica-operators.image" (dict "registry" $.Values.global.image.registry "repository" $.Values.upsertKineticaCrds.image.repository "tag" $.Values.upsertKineticaCrds.image.tag) -}}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pvc-cleanup
  namespace: {{ $ns }}
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": before-hook-creation
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pvc-cleanup
  namespace: {{ $ns }}
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": before-hook-creation
rules:
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    # watch: kubectl delete --wait observes deletion via a watch; without it
    # the wait degrades to noisy reflector-Forbidden retries (seen live 2026-08-06).
    verbs: ["get", "list", "watch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pvc-cleanup
  namespace: {{ $ns }}
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": before-hook-creation
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pvc-cleanup
subjects:
  - kind: ServiceAccount
    name: pvc-cleanup
    namespace: {{ $ns }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: pvc-cleanup
  namespace: {{ $ns }}
  annotations:
    "helm.sh/hook": pre-install
    # -8: after the RBAC above (-10), before the CRD upsert job (-5) purely so
    # its log sits first in the hook sequence; no real ordering dependency.
    "helm.sh/hook-weight": "-8"
    "helm.sh/hook-delete-policy": before-hook-creation
spec:
  backoffLimit: 0
  ttlSecondsAfterFinished: 86400
  template:
    spec:
      serviceAccountName: pvc-cleanup
      restartPolicy: Never
      securityContext:
        runAsNonRoot: true
        runAsUser: 65432
        fsGroup: 2000
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: kubectl
          image: {{ $img }}
          imagePullPolicy: IfNotPresent
          securityContext:
            allowPrivilegeEscalation: false
            runAsNonRoot: true
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
            seccompProfile:
              type: RuntimeDefault
          resources:
            requests:
              cpu: 50m
              memory: 64Mi
            limits:
              cpu: 200m
              memory: 128Mi
          command: ["/bin/sh", "-c"]
          args:
            - |
              set -eu
              NS='{{ $ns }}'
              echo "=== PVC cleanup in ${NS} ==="
              EXIT_CODE=0
              {{- range $pvcs }}
              echo "--- delete {{ . }} ---"
              # --wait so a finalizer-stuck PVC fails loudly here instead of
              # leaving the STS to rebind a half-deleted claim later.
              if OUT=$(kubectl -n "${NS}" delete pvc '{{ . }}' \
                  --ignore-not-found --wait=true --timeout=120s 2>&1); then
                echo "  OK: ${OUT:-not present}"
              else
                echo "  FAILED: ${OUT}"
                EXIT_CODE=1
              fi
              {{- end }}
              echo "Done. Exit code: ${EXIT_CODE}"
              exit ${EXIT_CODE}
{{- end }}
{{- end }}
