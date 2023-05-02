{{- define "porter-agent.installationClusterRole" }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    porter: "true"
    {{- include "porter-agent.labels" . | nindent 4 }}
  name: installation-service-account-role
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
- nonResourceURLs:
  - '*'
  verbs:
  - '*'
{{- end}}