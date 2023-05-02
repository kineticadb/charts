{{- define "porter-agent.configSecret" }}
apiVersion: v1
kind: Secret
stringData:
  config.toml: |
    debug = true
    debug-plugins = true
    default-secrets = "kubernetes-secrets"
    default-storage = "kubernetes-storage"

    [[secrets]]
    name = "kubernetes-secrets"
    plugin = "kubernetes.secret"

    [[storage]]
    name = "kubernetes-storage"
    plugin = "kubernetes.storage"
metadata:
  labels:
    {{- include "porter-agent.labels" . | nindent 4 }}
    porter: "true"
  {{- with .Values.porterAgent.serviceAccount.installation.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  name: {{ include "porter-agent.configSecretName" . }}
  namespace: {{ .Values.porterAgent.namespace  }}
type: {{ .Values.porterAgent.secret.config.type }}
{{- end }}