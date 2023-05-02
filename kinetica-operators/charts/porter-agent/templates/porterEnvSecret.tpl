{{- define "porter-agent.envSecret" }}
apiVersion: v1
kind: Secret
stringData:
  AZURE_STORAGE_CONNECTION_STRING: {{ .Values.porterAgent.secret.env.azure.AZURE_STORAGE_CONNECTION_STRING }}
  AZURE_CLIENT_SECRET: {{ .Values.porterAgent.secret.env.azure.AZURE_CLIENT_SECRET }}
  AZURE_CLIENT_ID:  {{ .Values.porterAgent.secret.env.azure.AZURE_CLIENT_ID }}
  AZURE_TENANT_ID:  {{ .Values.porterAgent.secret.env.azure.AZURE_TENANT_ID }}
type: {{ .Values.porterAgent.secret.env.type }}
metadata:
  labels:
    {{- include "porter-agent.labels" . | nindent 4 }}
    porter: "true"
  {{- with .Values.porterAgent.serviceAccount.installation.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  name: {{ include "porter-agent.envSecretName" . }}
  namespace: {{ .Values.porterAgent.namespace }}
{{- end }}