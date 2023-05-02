{{- define "porter-operator.managerRole" -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: porter-operator-manager-role
  labels:
    {{- include "porter-operator.labels" . | nindent 4 }}
rules:
  - apiGroups:
      - ""
    resources:
      - persistentvolumeclaims
    verbs:
      - create
      - delete
  - apiGroups:
      - ""
    resources:
      - pods
    verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
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
  - apiGroups:
      - porter.sh
    resources:
      - agentconfigs
    verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
  - apiGroups:
      - porter.sh
    resources:
      - installations
    verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
  - apiGroups:
      - porter.sh
    resources:
      - installations/finalizers
    verbs:
      - update
  - apiGroups:
      - porter.sh
    resources:
      - installations/status
    verbs:
      - get
      - patch
      - update
{{- end }}
