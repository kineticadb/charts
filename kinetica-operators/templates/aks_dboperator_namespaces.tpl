{{- define "kinetica-operators.aks-dboperator-namespaces" }}

{{ $gpudb_namespace := lookup 'v1' 'Namespace' '' 'gpudb' }}
{{- if not $gpudb_namespace -}}
---
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    helm.sh/hook: pre-install
    helm.sh/resource-policy: keep
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/part-of: kinetica
  name: gpudb
{{- end -}}

{{ $kml-active-analytics_namespace := lookup 'v1' 'Namespace' '' 'kml-active-analytics' }}
{{- if not $kml-active-analytics_namespace -}}
---
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    helm.sh/hook: pre-install
    helm.sh/resource-policy: keep
  name: kml-active-analytics
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
{{- end -}}

{{ $stats_namespace := lookup 'v1' 'Namespace' '' 'stats' }}
{{- if not $stats_namespace -}}
---
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    helm.sh/hook: pre-install
    helm.sh/resource-policy: keep
  name: stats
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