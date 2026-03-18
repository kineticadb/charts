{{- define "kinetica-operators.aks-dboperator-namespaces" }}

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
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/part-of: kinetica
  name: '{{ .Values.kineticacluster.namespace }}'
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
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/part-of: kinetica
  name: '{{ .Release.Namespace }}'
{{ end }}
{{ end }}

{{ if .Values.createNamespaces }}
{{ if not (lookup "v1" "Namespace" "" "nginx") }}
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
  name: nginx
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
    app: '{{ .Values.kineticacluster.namespace }}'
  name: '{{ .Values.kineticacluster.namespace }}'
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
    app: '{{ .Values.kineticacluster.namespace }}'
  name: '{{ .Values.kineticacluster.namespace }}'
  namespace: '{{ .Values.kineticacluster.namespace }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: '{{ .Values.kineticacluster.namespace }}'
subjects:
- kind: ServiceAccount
  name: default
  namespace: '{{ .Values.kineticacluster.namespace }}'

{{- end }}