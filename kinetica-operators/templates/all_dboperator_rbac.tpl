{{- define "kinetica-operators.all-dboperator-rbac" }}

---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: controller-manager
  namespace: '{{ .Release.Namespace }}'
  annotations:
    helm.sh/hook: pre-install
    helm.sh/hook-delete-policy: before-hook-creation
    helm.sh/hook-weight: '-10'

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: manager-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  annotations:
    helm.sh/hook: pre-install
    helm.sh/hook-delete-policy: before-hook-creation
    helm.sh/hook-weight: '-10'
rules:
- apiGroups:
  - ''
  resources:
  - configmaps
  - pods
  - secrets
  - services
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - ''
  resources:
  - events
  verbs:
  - create
  - patch
- apiGroups:
  - ''
  resources:
  - persistentvolumeclaims
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - ''
  resources:
  - pods/status
  - services/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticacluster
  - kineticaclusteradmins
  - kineticaclusterbackups
  - kineticaclusterelasticities
  - kineticaclusterresourcegroups
  - kineticaclusterrestores
  - kineticaclusters
  - kineticaclusterschemas
  - kineticagrants
  - kineticareleaseversions
  - kineticaroles
  - kineticausers
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticacluster/finalizers
  - kineticaclusteradmins/finalizers
  - kineticaclusterbackups/finalizers
  - kineticaclusters/finalizers
  verbs:
  - update
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticacluster/status
  - kineticaclusteradmins/status
  - kineticaclusterbackups/status
  - kineticaclusterelasticities/status
  - kineticaclusterresourcegroups/status
  - kineticaclusterrestores/status
  - kineticaclusters/status
  - kineticaclusterschemas/status
  - kineticagrants/status
  - kineticareleaseversions/status
  - kineticaroles/status
  - kineticausers/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - apps
  resources:
  - deployments
  - statefulsets
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
  - deployments/status
  - statefulsets/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - batch
  resources:
  - jobs
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses/status
  verbs:
  - get
  - patch
  - update

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: manager-role
  namespace: '{{ .Release.Namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  annotations:
    helm.sh/hook: pre-install
    helm.sh/hook-delete-policy: before-hook-creation
    helm.sh/hook-weight: '-10'
rules:
- apiGroups:
  - ''
  resources:
  - configmaps
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - ''
  resources:
  - events
  verbs:
  - create
  - get
  - list
  - patch
  - watch
- apiGroups:
  - apps
  resources:
  - deployments
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
  - deployments/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - coordination.k8s.io
  resources:
  - leases
  verbs:
  - create
  - get
  - list
  - update

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: leader-election-role
rules:
- apiGroups:
  - ''
  resources:
  - configmaps
  verbs:
  - get
  - list
  - watch
  - create
  - update
  - patch
  - delete
- apiGroups:
  - ''
  resources:
  - events
  verbs:
  - create

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: manager-rolebinding
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  annotations:
    helm.sh/hook: pre-install
    helm.sh/hook-delete-policy: before-hook-creation
    helm.sh/hook-weight: '-10'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: manager-role
subjects:
- kind: ServiceAccount
  name: controller-manager
  namespace: '{{ .Release.Namespace }}'

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: leader-election-rolebinding
  namespace: '{{ .Release.Namespace }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: leader-election-role
subjects:
- kind: ServiceAccount
  name: controller-manager
  namespace: '{{ .Release.Namespace }}'

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: manager-rolebinding
  namespace: '{{ .Release.Namespace }}'
  annotations:
    helm.sh/hook: pre-install
    helm.sh/hook-delete-policy: before-hook-creation
    helm.sh/hook-weight: '-10'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: manager-role
subjects:
- kind: ServiceAccount
  name: controller-manager
  namespace: '{{ .Release.Namespace }}'

{{- end }}