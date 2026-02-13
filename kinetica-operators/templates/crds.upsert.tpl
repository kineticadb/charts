{{- define "kinetica-operators.crds" }}

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
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
    helm.sh/hook-weight: '-5'
spec:
  ttlSecondsAfterFinished: 300
  backoffLimit: 3
  template:
    metadata:
      labels:
        app.kubernetes.io/name: kinetica-operators
        app.kubernetes.io/instance: '{{ .Release.Name }}'
    spec:
      serviceAccountName: kineticacluster-operator
      securityContext:
        runAsNonRoot: true
        runAsUser: 65432
        fsGroup: 2000
      containers:
      - name: upsert-kinetica-crds-job
        image: "{{ .Values.upsertKineticaCrds.image.repository }}:{{ .Values.upsertKineticaCrds.image.tag }}"
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
                if kubectl replace -f "$F"; then
                  echo "  SUCCESS: $F"
                else
                  echo "  FAILED: $F"
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
      restartPolicy: Never

{{- end }}
