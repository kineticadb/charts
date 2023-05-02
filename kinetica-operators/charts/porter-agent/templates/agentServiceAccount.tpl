{{- define "porter-agent.agentServiceAccount" }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "porter-agent.agentServiceAccountName" . }}
  namespace: {{ .Values.porterAgent.namespace }}
  labels:
    {{- include "porter-agent.agentLabels" . | nindent 4 }}
  {{- with .Values.porterAgent.serviceAccount.agent.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
