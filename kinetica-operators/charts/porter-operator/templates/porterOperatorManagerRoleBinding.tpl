{{- define "porter-operator.managerRoleBinding" -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: porter-operator-manager-rolebinding
  labels:
    {{- include "porter-operator.labels" . | nindent 4 }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: porter-operator-manager-role
subjects:
  - kind: ServiceAccount
    name: {{ include "porter-operator.serviceAccountName" . }}
    namespace: {{ .Values.porterOperator.namespace }}
{{- end }}