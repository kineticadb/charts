{{- define "kinetica-operators.crds" }}

---
apiVersion: batch/v1
kind: Job
metadata:
  name: '{{ .Release.Name }}-upsert-kinetica-crds'
  namespace: '{{ .Release.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  annotations:
    helm.sh/hook: pre-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
    helm.sh/hook-weight: '-5'
spec:
  template:
    spec:
      containers:
      - name: upsert-kinetica-crds-job
        image: "{{ .Values.upsertKineticaCrds.image.repository }}:{{ .Values.upsertKineticaCrds.image.tag }}"
      restartPolicy: Never

{{- end }}
