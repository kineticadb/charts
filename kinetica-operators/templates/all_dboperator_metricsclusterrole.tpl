{{- define "kinetica-operators.all-dboperator-metricsclusterrole" }}

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: metrics-auth-role
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- apiGroups:
  - authentication.k8s.io
  resources:
  - tokenreviews
  verbs:
  - create
- apiGroups:
  - authorization.k8s.io
  resources:
  - subjectaccessreviews
  verbs:
  - create

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: metrics-reader
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- nonResourceURLs:
  - /metrics
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: metrics-auth-rolebinding
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: metrics-auth-role
subjects:
- kind: ServiceAccount
  name: '{{ .Values.dbOperator.serviceAccountName | default "controller-manager" }}'
  namespace: '{{ .Release.Namespace }}'

{{- end }}