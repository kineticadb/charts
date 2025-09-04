{{- define "kinetica-operators.local-dboperator-namespaces" }}

{{ $gpudb_namespace := lookup 'v1' 'Namespace' '' 'gpudb' }}
{{- if not $gpudb_namespace -}}
---
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    helm.sh/hook: pre-install
    helm.sh/resource-policy: keep
  name: gpudb
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
{{- end -}}

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: gpudb
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
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: gpudb
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