{{- define "kinetica-operators.local-dboperator-namespaces" }}

---
apiVersion: v1
kind: Namespace
metadata:
  name: gpudb
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: gpudb
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
  name: gpudb
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

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app: gpudb
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
  name: gpudb
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: gpudb
subjects:
- kind: ServiceAccount
  name: default
  namespace: gpudb

{{- end }}