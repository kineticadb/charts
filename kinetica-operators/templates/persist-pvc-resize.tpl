{{- with .Values.persistPvcResize }}
{{- if .enabled }}
# One-shot resize of the persist-tier PVCs.
# Runs as a helm pre-upgrade hook under a dedicated SA scoped to patch PVCs
# in the target namespace. The helm-chart-operator SA (which applies this
# chart in Rubix/Apollo) has ["*"] verbs on rolebindings/roles/serviceaccounts
# /pvcs in the gpudb namespace per rubix-rbac.yaml, which is what makes this
# bundle installable.
#
# Standard usage — declare the new disk size on the DB CR and enable the Job:
#
#   kineticacluster:
#     gpudbCluster:
#       config:
#         tieredStorage:
#           persistTier:
#             default:
#               limit: 130Gi              # <-- the disk size (single source of truth)
#   persistPvcResize:
#     enabled: true                       # <-- runs the resize Job on next upgrade
#
# After it succeeds, you can either:
#   - Leave persistPvcResize.enabled=true: Phase 1 detects "already at target"
#     and writes a sentinel annotation that tells Phase 2 to skip the pod
#     restart. Subsequent no-op upgrades cost ~1s and zero disruption.
#   - Flip enabled=false to skip rendering the resize resources entirely.
#
# Escape-hatch overrides (rarely needed):
#   persistPvcResize:
#     enabled: true
#     namespace: db-1                     # if DB lives outside kineticacluster.namespace
#     size: 130Gi                         # if you need to resize to a different value
#                                         # than persistTier.default.limit (advanced)
#     pvcNames:                           # explicit list for non-standard naming
#       - my-cluster-persist-gpudb-0
#     dbPodNames:                         # explicit list for non-standard naming
#       - gpudb-0
{{- /*
  Namespace precedence: explicit persistPvcResize.namespace override >
  kineticacluster.namespace (source of truth where the DB lives) > "gpudb" fallback.
*/ -}}
{{- $ns := .namespace | default $.Values.kineticacluster.namespace | default "gpudb" -}}
{{- /*
  Size precedence: explicit persistPvcResize.size override (escape hatch for
  staged migrations where you want PVCs at a different size than the DB CR
  declares) > kineticacluster.gpudbCluster.config.tieredStorage.persistTier.default.limit
  (the canonical source — same field that drives the operator's VolumeClaimTemplate
  sizing). Failing render if neither is set, because we can't infer a target.
*/ -}}
{{- $size := .size | default ((((((($.Values.kineticacluster).gpudbCluster).config).tieredStorage).persistTier).default).limit) -}}
{{- if not $size -}}
  {{- fail "persistPvcResize is enabled but no target size: set kineticacluster.gpudbCluster.config.tieredStorage.persistTier.default.limit (recommended) or persistPvcResize.size (escape hatch)." -}}
{{- end -}}
{{- /*
  Derive PVC and pod names from the cluster name + replica count.
  The DB operator creates the StatefulSet with name "gpudb" in the cluster's
  namespace. The persist tier's volumeClaimTemplate is named
  "<clusterName>-persist", so PVCs follow K8s STS naming:
      <clusterName>-persist-gpudb-<ordinal>
  Pods follow the standard STS naming:
      gpudb-<ordinal>
  Both lists can still be overridden by setting persistPvcResize.pvcNames
  or persistPvcResize.dbPodNames explicitly (escape hatch for non-standard
  setups).
*/ -}}
{{- $clusterName := $.Values.kineticacluster.gpudbCluster.clusterName | required "kineticacluster.gpudbCluster.clusterName is required for persistPvcResize" -}}
{{- $replicas := $.Values.kineticacluster.gpudbCluster.replicas | default 3 | int -}}
{{- $stsName := "gpudb" -}}
{{- $pvcs := .pvcNames -}}
{{- if not $pvcs -}}
  {{- $pvcs = list -}}
  {{- range $i, $_ := until $replicas -}}
    {{- $pvcs = append $pvcs (printf "%s-persist-%s-%d" $clusterName $stsName $i) -}}
  {{- end -}}
{{- end -}}
{{- $img := include "kinetica-operators.image" (dict "registry" $.Values.global.image.registry "repository" $.Values.upsertKineticaCrds.image.repository "tag" $.Values.upsertKineticaCrds.image.tag) -}}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: persist-pvc-resizer
  namespace: {{ $ns }}
  annotations:
    "helm.sh/hook": pre-upgrade
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": before-hook-creation
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: persist-pvc-resizer
  namespace: {{ $ns }}
  annotations:
    "helm.sh/hook": pre-upgrade
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": before-hook-creation
rules:
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "patch"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims/status"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: persist-pvc-resizer
  namespace: {{ $ns }}
  annotations:
    "helm.sh/hook": pre-upgrade
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": before-hook-creation
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: persist-pvc-resizer
subjects:
  - kind: ServiceAccount
    name: persist-pvc-resizer
    namespace: {{ $ns }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: persist-pvc-resizer
  namespace: {{ $ns }}
  annotations:
    "helm.sh/hook": pre-upgrade
    "helm.sh/hook-weight": "0"
    "helm.sh/hook-delete-policy": before-hook-creation
spec:
  backoffLimit: 0
  ttlSecondsAfterFinished: 86400
  template:
    spec:
      serviceAccountName: persist-pvc-resizer
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
              SIZE='{{ $size }}'
              # Total wait budget for CSI to finish controller-side ModifyVolume +
              # node-side NodeExpandVolume across all PVCs. gp3 online resize
              # typically completes in 30-60s; budget generously but stay under
              # the 5-minute helm-hook ceiling.
              RESIZE_WAIT_SECS=240
              echo "Namespace: ${NS}"
              echo "Target size: ${SIZE}"
              echo "Resize-completion wait budget: ${RESIZE_WAIT_SECS}s"
              EXIT_CODE=0
              # Tracks whether any PVC was actually patched this run. Used at the
              # end to write a sentinel annotation Phase 2 reads to decide whether
              # a pod restart is needed.
              PATCHED_ANY=false

              # ----- Phase 1: issue all patches (or note already-at-target) -----
              {{- range $pvcs }}
              echo "--- patch {{ . }} ---"
              if CURRENT=$(kubectl -n "${NS}" get pvc {{ . }} \
                  -o jsonpath='{.spec.resources.requests.storage}' 2>&1); then
                echo "  current spec.requests.storage: ${CURRENT}"
                CAP=$(kubectl -n "${NS}" get pvc {{ . }} \
                    -o jsonpath='{.status.capacity.storage}' 2>/dev/null || echo "?")
                echo "  current status.capacity.storage: ${CAP}"
                if [ "${CURRENT}" = "${SIZE}" ]; then
                  echo "  spec already at target; no patch issued"
                else
                  if PATCH_OUT=$(kubectl -n "${NS}" patch pvc {{ . }} \
                      --type merge \
                      -p "{\"spec\":{\"resources\":{\"requests\":{\"storage\":\"${SIZE}\"}}}}" 2>&1); then
                    echo "  PATCH OK: ${PATCH_OUT}"
                    PATCHED_ANY=true
                  else
                    echo "  PATCH FAILED: ${PATCH_OUT}"
                    EXIT_CODE=1
                  fi
                fi
              else
                echo "  GET FAILED: ${CURRENT}"
                EXIT_CODE=1
              fi
              {{- end }}

              # If any patch failed there's no point waiting — exit now.
              if [ "${EXIT_CODE}" -ne 0 ]; then
                echo "One or more patches failed; skipping resize-completion wait."
                exit ${EXIT_CODE}
              fi

              # ----- Phase 2: wait for status.capacity to match spec across all PVCs -----
              # Pod restart (post-upgrade hook) must NOT fire until CSI has finished
              # both controller-side (EBS ModifyVolume) and node-side (NodeExpandVolume)
              # resize, otherwise new pods may mount a still-resizing volume and
              # cache stale capacity at startup.
              echo "--- waiting for CSI to complete resize on all PVCs ---"
              END=$(( $(date +%s) + RESIZE_WAIT_SECS ))
              while [ "$(date +%s)" -lt "${END}" ]; do
                ALL_DONE=true
                STATUS_LINE=""
                {{- range $pvcs }}
                CAP=$(kubectl -n "${NS}" get pvc {{ . }} \
                    -o jsonpath='{.status.capacity.storage}' 2>/dev/null || echo "?")
                CONDITIONS=$(kubectl -n "${NS}" get pvc {{ . }} \
                    -o jsonpath='{.status.conditions[*].type}' 2>/dev/null || echo "")
                if [ "${CAP}" = "${SIZE}" ] && [ -z "${CONDITIONS}" ]; then
                  STATUS_LINE="${STATUS_LINE} {{ . }}=${CAP}✓"
                else
                  STATUS_LINE="${STATUS_LINE} {{ . }}=${CAP}(${CONDITIONS:-none})"
                  ALL_DONE=false
                fi
                {{- end }}
                echo "  $(date +%H:%M:%S)${STATUS_LINE}"
                if [ "${ALL_DONE}" = "true" ]; then
                  echo "All PVCs reached target size with no pending resize conditions."
                  # Sentinel for Phase 2: "patched" = we did real work, restart pods;
                  # "noop" = nothing changed this run, skip the disruption. Written on
                  # the first PVC because (a) the annotation is colocated with the
                  # thing it describes, (b) the existing patch perm covers annotate.
                  # Failure to annotate is non-fatal — Phase 2 defaults to restart-on-
                  # unknown to stay safe.
                  RESULT=$([ "${PATCHED_ANY}" = "true" ] && echo "patched" || echo "noop")
                  if ANN_OUT=$(kubectl -n "${NS}" annotate pvc {{ index $pvcs 0 }} \
                      "persist-pvc-resize/last-result=${RESULT}" \
                      "persist-pvc-resize/last-run-at=$(date -Iseconds)" \
                      --overwrite 2>&1); then
                    echo "Sentinel written: last-result=${RESULT}"
                  else
                    echo "WARNING: failed to write sentinel annotation: ${ANN_OUT}"
                    echo "Phase 2 will default to restart-on-unknown."
                  fi
                  echo "Done. Exit code: 0"
                  exit 0
                fi
                sleep 5
              done

              echo "TIMEOUT after ${RESIZE_WAIT_SECS}s — one or more PVCs did not finish resize:"
              {{- range $pvcs }}
              FINAL_CAP=$(kubectl -n "${NS}" get pvc {{ . }} \
                  -o jsonpath='{.status.capacity.storage}' 2>/dev/null || echo "?")
              FINAL_COND=$(kubectl -n "${NS}" get pvc {{ . }} \
                  -o jsonpath='{.status.conditions[*].type}' 2>/dev/null || echo "")
              echo "  {{ . }}: capacity=${FINAL_CAP} conditions=${FINAL_COND:-none}"
              {{- end }}
              echo "Done. Exit code: 1 (resize incomplete; post-upgrade restart will be skipped if hooks chain on failure)"
              exit 1

{{- /*
  Pod restart is not optional. The DB only loads tier.persist.default.limit
  (and other configmap-derived settings) at container startup, so a resize
  without a restart leaves GPUdb's internal accounting stale relative to
  actual disk size — a silently-bad state. Always restart.

  Derive pod names if not explicitly provided. STS-managed pods follow
  "<stsName>-<ordinal>" naming, where stsName is "gpudb".
*/ -}}
{{- $dbPodNames := .dbPodNames -}}
{{- if not $dbPodNames -}}
  {{- $dbPodNames = list -}}
  {{- range $i, $_ := until $replicas -}}
    {{- $dbPodNames = append $dbPodNames (printf "%s-%d" $stsName $i) -}}
  {{- end -}}
{{- end }}
---
# Post-upgrade pod restart so the DB picks up new disk sizes / regenerated
# gpudb.conf after the pre-upgrade PVC patches. Lives at hook-weight 0 so
# it runs after the main chart upgrade has settled (operator has reconciled
# the CR change, configmap regenerated, etc.). Uses a separate SA/Role
# scoped just to delete+get+list on pods.
apiVersion: v1
kind: ServiceAccount
metadata:
  name: persist-pvc-restart
  namespace: {{ $ns }}
  annotations:
    "helm.sh/hook": post-upgrade
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": before-hook-creation
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: persist-pvc-restart
  namespace: {{ $ns }}
  annotations:
    "helm.sh/hook": post-upgrade
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": before-hook-creation
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "delete"]
  # Needed so Phase 2 can read the sentinel annotation Phase 1 wrote on the
  # first PVC. If Phase 1 reported "noop" (no patches issued), Phase 2 exits
  # early without restarting pods.
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: persist-pvc-restart
  namespace: {{ $ns }}
  annotations:
    "helm.sh/hook": post-upgrade
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": before-hook-creation
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: persist-pvc-restart
subjects:
  - kind: ServiceAccount
    name: persist-pvc-restart
    namespace: {{ $ns }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: persist-pvc-restart
  namespace: {{ $ns }}
  annotations:
    "helm.sh/hook": post-upgrade
    "helm.sh/hook-weight": "0"
    "helm.sh/hook-delete-policy": before-hook-creation
spec:
  backoffLimit: 0
  ttlSecondsAfterFinished: 86400
  template:
    spec:
      serviceAccountName: persist-pvc-restart
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
              WAIT_SECS=300
              echo "Namespace: ${NS}"
              echo "Wait timeout per pod: ${WAIT_SECS}s"
              EXIT_CODE=0

              # Sentinel check: Phase 1 annotates the first PVC with "noop" when no
              # patches were actually needed (e.g., persistTier.default.limit unchanged
              # across upgrades but persistPvcResize.enabled=true left on). In that
              # case a pod restart is pure disruption with no benefit — skip out.
              # Bracket-form jsonpath because the annotation key contains a slash.
              # Default to "" on failure → falls through to restart-on-unknown (safe).
              LAST_RESULT=$(kubectl -n "${NS}" get pvc {{ index $pvcs 0 }} \
                  -o jsonpath="{.metadata.annotations['persist-pvc-resize/last-result']}" \
                  2>/dev/null || echo "")
              if [ "${LAST_RESULT}" = "noop" ]; then
                echo "Phase 1 reported no patches needed (last-result=noop); skipping pod restart."
                echo "Done. Exit code: 0"
                exit 0
              fi
              echo "Phase 1 result: ${LAST_RESULT:-unknown}; proceeding with pod restart."

              # Delete all pods in parallel (Apollo's STS uses podManagementPolicy:
              # Parallel, so K8s will recreate them concurrently). --wait=false so
              # this step returns immediately and we don't burn budget on termination.
              {{- range $dbPodNames }}
              echo "--- deleting pod {{ . }} ---"
              if DEL_OUT=$(kubectl -n "${NS}" delete pod {{ . }} --wait=false --ignore-not-found 2>&1); then
                echo "  DELETE OK: ${DEL_OUT}"
              else
                echo "  DELETE FAILED: ${DEL_OUT}"
                EXIT_CODE=1
              fi
              {{- end }}

              # Brief settle so STS controller has time to begin recreate before we poll.
              sleep 5

              # Wait for each pod to come back Ready. Polled loop (not kubectl wait)
              # because the pod may not exist yet at the moment of the call window.
              {{- range $dbPodNames }}
              echo "--- waiting for {{ . }} to be Ready (up to ${WAIT_SECS}s) ---"
              END=$(( $(date +%s) + WAIT_SECS ))
              READY=""
              while [ "$(date +%s)" -lt "${END}" ]; do
                READY=$(kubectl -n "${NS}" get pod {{ . }} \
                    -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' \
                    2>/dev/null || echo "")
                if [ "${READY}" = "True" ]; then
                  echo "  {{ . }} is Ready"
                  break
                fi
                sleep 5
              done
              if [ "${READY}" != "True" ]; then
                echo "  {{ . }} did NOT become Ready in ${WAIT_SECS}s"
                EXIT_CODE=1
              fi
              {{- end }}

              echo "Done. Exit code: ${EXIT_CODE}"
              exit ${EXIT_CODE}
{{- end }}
{{- end }}
