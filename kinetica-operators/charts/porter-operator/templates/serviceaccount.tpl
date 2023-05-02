
{{- define "porter-operator.serviceAccount" }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "porter-operator.serviceAccountName" . }}
  namespace: {{ .Values.porterOperator.namespace }}
  labels:
    {{- include "porter-operator.labels" . | nindent 4 }}
  {{- with .Values.porterOperator.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}

{{- end}}
