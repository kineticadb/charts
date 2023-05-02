{{- define "porter-agent.roleBinding" }}
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ include "porter-agent.agentServiceAccountName" . }}
  namespace: {{ .Values.porterAgent.namespace  }}
  labels:
    {{- include "porter-agent.agentLabels" . | nindent 4 }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: porter-operator-agent-role
subjects:
  - kind: ServiceAccount
    name: {{ include "porter-agent.agentServiceAccountName" . }}
    namespace: {{ .Values.porterAgent.namespace  }}
{{- end}}