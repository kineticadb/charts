{{- define "kinetica-operators.all-wboperator-baseRbac" }}

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: workbench-reader-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- apiGroups:
  - workbench.com.kinetica
  resources:
  - workbenches
  - workbenchupgrades
  - workbenchoperatorupgrades
  verbs:
  - get
  - watch
  - list

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: workbench-secret-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- apiGroups:
  - ''
  resources:
  - secrets
  verbs:
  - get
  - watch
  - list
  - create
  - update
  - patch
  - delete

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: workbench-upgrades-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- apiGroups:
  - workbench.com.kinetica
  resources:
  - workbenchupgrades
  - workbenchoperatorupgrades
  verbs:
  - get
  - watch
  - list
  - create
  - update
  - patch
  - delete

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: workbench-velero-restores-reader-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- apiGroups:
  - velero.io
  resources:
  - restores
  verbs:
  - get
  - watch
  - list

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: workbench-reader-role-binding
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: workbench-reader-role
subjects:
- kind: ServiceAccount
  name: workbench-service-account
  namespace: kinetica-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: workbench-secret-role-binding
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: workbench-secret-role
subjects:
- kind: ServiceAccount
  name: workbench-service-account
  namespace: kinetica-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: workbench-upgrades-role-binding
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: workbench-upgrades-role
subjects:
- kind: ServiceAccount
  name: workbench-service-account
  namespace: kinetica-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: workbench-velero-restores-reader-role-binding
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: workbench-velero-restores-reader-role
subjects:
- kind: ServiceAccount
  name: workbench-service-account
  namespace: kinetica-system

{{- end }}