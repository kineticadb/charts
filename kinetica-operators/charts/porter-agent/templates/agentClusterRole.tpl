{{- define "porter-agent.clusterRole" }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: porter-operator-agent-role
  labels:
    {{- include "porter-agent.labels" . | nindent 4 }}
rules:
  - apiGroups:
      - ""
    resources:
      - pods
      - namespaces
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - pods/log
    verbs:
      - get
      - list
  - apiGroups:
      - ""
    resources:
      - secrets
    verbs:
      - create
      - delete
      - get
      - list
      - watch
  - apiGroups:
      - batch
    resources:
      - jobs
    verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
{{- end }}