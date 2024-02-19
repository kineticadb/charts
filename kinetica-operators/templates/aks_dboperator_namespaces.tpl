{{- define "kinetica-operators.aks-dboperator-namespaces" }}

---
apiVersion: v1
kind: Namespace
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/part-of: kinetica
  name: gpudb

---
apiVersion: v1
kind: Namespace
metadata:
  name: kml-active-analytics
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'

---
apiVersion: v1
kind: Namespace
metadata:
  name: stats
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