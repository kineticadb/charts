{{- define "porter-operator.leaderElectionRoleBinding" -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: porter-operator-leader-election-rolebinding
  namespace: {{ .Values.porterOperator.namespace }}
  labels:
    {{- include "porter-operator.labels" . | nindent 4 }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: porter-operator-leader-election-role
subjects:
  - kind: ServiceAccount
    name: {{ include "porter-operator.serviceAccountName" . }}
    namespace: {{ .Values.porterOperator.namespace }}
{{- end}}