{{- define "porter-operator.metricsReaderRole" -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: porter-operator-metrics-reader-role
  labels:
    {{- include "porter-operator.labels" . | nindent 4 }}
rules:
  - nonResourceURLs:
      - /metrics
    verbs:
      - get
{{- end -}}