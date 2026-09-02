{{- define "kinetica-operators.all-wboperator-metricsclusterrole" }}

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: workbench-operator-metrics-auth-role
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
  name: workbench-operator-metrics-reader
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
  name: workbench-operator-metrics-auth-rolebinding
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: workbench-operator-metrics-auth-role
subjects:
- kind: ServiceAccount
  name: workbench-operator-service-account
  namespace: '{{ .Release.Namespace }}'

{{- end }}