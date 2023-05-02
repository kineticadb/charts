{{- define "porter-agent.agentConfig" }}
apiVersion: porter.sh/v1
kind: AgentConfig
metadata:
  name: {{ .Values.porterAgent.name }}
  namespace: {{ .Values.porterAgent.Namespace  }}
  labels:
    {{- include "porter-agent.agentLabels" . | nindent 4 }}
spec:
  porterRepository: {{ .Values.porterAgent.image.repository }}
  porterVersion: v{{ include "porter-agent.imageTag" . }}
  serviceAccount: porter-agent
  installationServiceAccount: {{ include "porter-agent.installationServiceAccountName" . }}
{{- end }}