{{- define "kinetica-operators.aks-dboperator-namespaces" }}

{{ if .Values.createNamespaces }}
{{ if not (lookup "v1" "Namespace" "" "gpudb") }}
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
{{ end }}
{{ end }}

{{ if .Values.createNamespaces }}
{{ if not (lookup "v1" "Namespace" "" "kml-active-analytics") }}
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
{{ end }}
{{ end }}

{{ if .Values.createNamespaces }}
{{ if not (lookup "v1" "Namespace" "" "stats") }}
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
{{ end }}
{{ end }}

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