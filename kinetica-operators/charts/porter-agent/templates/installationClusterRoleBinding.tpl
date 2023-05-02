{{- define "porter-agent.installationClusterRoleBinding" }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    porter: "true"
  name: installation-service-account-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: installation-service-account-role
subjects:
- kind: ServiceAccount
  name: {{ include "porter-agent.installationServiceAccountName" . }}
  namespace: {{ .Values.porterAgent.namespace  }}
{{- end }}