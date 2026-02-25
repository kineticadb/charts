{{- define "kinetica-operators.saas-eks-dboperator-namespaces" }}

{{ if .Values.createNamespaces }}
{{ if not (lookup "v1" "Namespace" "" "cert-manager") }}
---
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    helm.sh/hook: pre-install
    helm.sh/hook-weight: '-15'
    helm.sh/resource-policy: keep
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/part-of: kinetica
  name: cert-manager
{{ end }}
{{ end }}

{{ if .Values.createNamespaces }}
{{ if not (lookup "v1" "Namespace" "" "{{ .Values.kineticacluster.namespace }}") }}
---
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    helm.sh/hook: pre-install
    helm.sh/hook-weight: '-15'
    helm.sh/resource-policy: keep
  name: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
{{ end }}
{{ end }}

{{ if .Values.createNamespaces }}
{{ if not (lookup "v1" "Namespace" "" "{{ .Release.Namespace }}") }}
---
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    helm.sh/hook: pre-install
    helm.sh/hook-weight: '-15'
    helm.sh/resource-policy: keep
  name: '{{ .Release.Namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
{{ end }}
{{ end }}

{{ if .Values.createNamespaces }}
{{ if not (lookup "v1" "Namespace" "" "nginx") }}
---
apiVersion: v1
kind: Namespace
metadata:
  name: nginx
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
  namespace: '{{ .Values.kineticacluster.namespace }}'
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
  namespace: '{{ .Values.kineticacluster.namespace }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: gpudb
subjects:
- kind: ServiceAccount
  name: default
  namespace: '{{ .Values.kineticacluster.namespace }}'

{{- end }}