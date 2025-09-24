{{- define "kinetica-operators.local-dboperator-namespaces" }}

{{ if .Values.createNamespaces }}
{{ if not (lookup "v1" "Namespace" "" "gpudb") }}
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
{{ end }}
{{ end }}

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: gpudb
  name: gpudb
  namespace: gpudb
rules:
- apiGroups:
  - ''
  resources:
  - configmaps
  - events
  - pods
  - pods/status
  - secrets
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - apps
  resources:
  - statefulsets
  - statefulsets/status
  verbs:
  - get
  - list
  - watch

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: gpudb
  name: gpudb
  namespace: gpudb
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: gpudb
subjects:
- kind: ServiceAccount
  name: default
  namespace: gpudb

{{- end }}