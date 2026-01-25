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
      containers:
      - name: upsert-kinetica-crds-job
        image: "{{ .Values.upsertKineticaCrds.image.repository }}:{{ .Values.upsertKineticaCrds.image.tag }}"
        command: ["/bin/bash", "-c"]
        args:
          - |
            set -e
            echo "=== Checking CRD permissions ==="
            echo -n "can-i get customresourcedefinitions: "
            kubectl auth can-i get customresourcedefinitions || true
            echo -n "can-i update customresourcedefinitions: "
            kubectl auth can-i update customresourcedefinitions || true
            echo ""
            echo "=== Starting CRD replacements ==="
            FAILED=0
            for F in /crds/db-crds/* /crds/wb-crds/*; do
              if [ -f "$F" ]; then
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
