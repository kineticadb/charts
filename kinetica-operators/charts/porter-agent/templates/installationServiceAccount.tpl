{{- define "porter-agent.installationServiceAccount" }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "porter-agent.installationServiceAccountName" . }}
  namespace: {{ .Values.porterAgent.namespace  }}
  labels:
    {{- include "porter-agent.labels" . | nindent 4 }}
  {{- with .Values.porterAgent.serviceAccount.installation.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
