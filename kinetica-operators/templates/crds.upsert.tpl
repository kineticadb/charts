{{- define "kinetica-operators.crds" }}
{{- if .Values.upsertKineticaCrds.serviceAccountName }}

---
# Dedicated ServiceAccount for the upsert Job (rendered only when
# upsertKineticaCrds.serviceAccountName is set). pre-install-only + weight -10
# mirrors the proven operator-SA hook pattern: fresh installs create it before
# the Job (-5) runs; upgrades never touch it, so an SA already on the cluster
# (e.g. kineticacluster-operator from a pre-rename release, still named by the
# platform-provisioned CRD-update ClusterRoleBinding on Rubix) is left alone.
apiVersion: v1
kind: ServiceAccount
metadata:
  name: '{{ .Values.upsertKineticaCrds.serviceAccountName }}'
  namespace: '{{ .Release.Namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  annotations:
    helm.sh/hook: pre-install
    helm.sh/hook-delete-policy: before-hook-creation
    helm.sh/hook-weight: '-10'
{{- end }}

---
apiVersion: batch/v1
kind: Job
metadata:
  name: '{{ .Release.Name }}-upsert-kinetica-crds'
  namespace: '{{ .Release.Namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  annotations:
    helm.sh/hook: pre-install,pre-upgrade
    helm.sh/hook-delete-policy: before-hook-creation
    helm.sh/hook-weight: '-5'
spec:
  # 20-minute log-inspection window, then K8s TTL controller deletes the Job.
  ttlSecondsAfterFinished: 1200
  backoffLimit: 3
  template:
    metadata:
      labels:
        app.kubernetes.io/name: kinetica-operators
        app.kubernetes.io/instance: '{{ .Release.Name }}'
    spec:
      serviceAccountName: '{{ .Values.upsertKineticaCrds.serviceAccountName | default "controller-manager" }}'
      securityContext:
        runAsNonRoot: true
        runAsUser: 65432
        fsGroup: 2000
      containers:
      - name: upsert-kinetica-crds-job
        image: "{{ include "kinetica-operators.image" (dict "registry" .Values.global.image.registry "repository" .Values.upsertKineticaCrds.image.repository "tag" .Values.upsertKineticaCrds.image.tag) }}"
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          seccompProfile:
            type: RuntimeDefault
        command: ["/bin/bash", "-c"]
        args:
          - |
            set -e
            echo "=== Starting CRD replacements ==="
            FAILED=0
            for F in /crds/db-crds/* /crds/wb-crds/*; do
              if [ -f "$F" ]; then
                CRD_NAME=$(grep -m1 '^  name:' "$F" | awk '{print $2}')
                if ! kubectl get crd "$CRD_NAME" >/dev/null 2>&1; then
                  echo "Skipping (not present): $F"
                  continue
                fi
                echo "Processing: $F"
                if ERR="$(kubectl replace -f "$F" 2>&1)"; then
                  echo "  SUCCESS: $F - ${CRD_NAME}"
                else
                  printf 'FAILED %s: %s\n' "$CRD" "$(printf '%s' "$ERR" | head -1)"
                  FAILED=$((FAILED + 1))
                fi
              fi
            done
            echo ""
            echo "=== CRD replacement complete ==="
            if [ $FAILED -gt 0 ]; then
              echo "WARNING: $FAILED CRD(s) failed to update"
              exit 1
            fi
            echo "All CRDs updated successfully"
      restartPolicy: OnFailure

{{- end }}
