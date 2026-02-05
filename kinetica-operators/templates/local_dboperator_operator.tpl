{{- define "kinetica-operators.local-dboperator-operator" }}

---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-controller-manager
  namespace: kinetica-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-leader-election-role
  namespace: kinetica-system
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
  - coordination.k8s.io
  resources:
  - leases
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
  - patch

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticacluster-admin-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusters
  verbs:
  - '*'
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusters/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticacluster-editor-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusters
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
  - kineticaclusters/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticacluster-viewer-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusters
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusters/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusteradmin-admin-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusteradmins
  verbs:
  - '*'
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusteradmins/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusteradmin-editor-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusteradmins
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
  - kineticaclusteradmins/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusteradmin-viewer-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusteradmins
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusteradmins/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusterbackup-admin-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterbackups
  verbs:
  - '*'
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterbackups/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusterbackup-editor-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterbackups
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
  - kineticaclusterbackups/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusterbackup-viewer-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterbackups
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterbackups/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusterelasticity-admin-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterelasticities
  verbs:
  - '*'
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterelasticities/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusterelasticity-editor-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterelasticities
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
  - kineticaclusterelasticities/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusterelasticity-viewer-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterelasticities
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterelasticities/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusterresourcegroup-admin-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterresourcegroups
  verbs:
  - '*'
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterresourcegroups/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusterresourcegroup-editor-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterresourcegroups
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
  - kineticaclusterresourcegroups/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusterresourcegroup-viewer-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterresourcegroups
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterresourcegroups/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusterrestore-admin-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterrestores
  verbs:
  - '*'
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterrestores/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusterrestore-editor-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterrestores
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
  - kineticaclusterrestores/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusterrestore-viewer-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterrestores
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterrestores/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusterschema-admin-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterschemas
  verbs:
  - '*'
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterschemas/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusterschema-editor-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterschemas
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
  - kineticaclusterschemas/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticaclusterschema-viewer-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterschemas
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterschemas/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticagrant-admin-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticagrants
  verbs:
  - '*'
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticagrants/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticagrant-editor-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticagrants
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
  - kineticagrants/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticagrant-viewer-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticagrants
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticagrants/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticareleaseversion-admin-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticareleaseversions
  verbs:
  - '*'
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticareleaseversions/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticareleaseversion-editor-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticareleaseversions
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
  - kineticareleaseversions/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticareleaseversion-viewer-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticareleaseversions
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticareleaseversions/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticarole-admin-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaroles
  verbs:
  - '*'
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaroles/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticarole-editor-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaroles
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
  - kineticaroles/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticarole-viewer-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaroles
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaroles/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticauser-admin-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticausers
  verbs:
  - '*'
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticausers/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticauser-editor-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
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
  - kineticausers/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-kineticauser-viewer-role
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticausers
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticausers/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kineticaoperator-manager-role
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- apiGroups:
  - ''
  resources:
  - configmaps
  - events
  - namespaces
  - nodes
  - persistentvolumes
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
  - configmaps/status
  - events/status
  - namespaces/status
  - nodes/status
  - persistentvolumeclaims/status
  - persistentvolumes/status
  - pods/status
  - secrets/status
  - services/status
  verbs:
  - get
  - patch
  - update
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
  - app.kinetica.com
  resources:
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
  - kineticaclusteradmins/finalizers
  - kineticaclusterbackups/finalizers
  - kineticaclusters/finalizers
  verbs:
  - update
- apiGroups:
  - app.kinetica.com
  resources:
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
  - daemonsets
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
  - daemonsets/status
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
  - coordination.k8s.io
  resources:
  - leases
  verbs:
  - create
  - get
  - list
  - update
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
- apiGroups:
  - storage.k8s.io
  resources:
  - storageclasses
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - storage.k8s.io
  resources:
  - storageclasses/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - velero.io
  resources:
  - backups
  - deletebackuprequests
  - restores
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - velero.io
  resources:
  - backups/status
  - restores/status
  verbs:
  - get
  - patch
  - update

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kineticaoperator-metrics-auth-role
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
  name: kineticaoperator-metrics-reader
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
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-leader-election-rolebinding
  namespace: kinetica-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kineticaoperator-leader-election-role
subjects:
- kind: ServiceAccount
  name: kineticaoperator-controller-manager
  namespace: kinetica-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-manager-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kineticaoperator-manager-role
subjects:
- kind: ServiceAccount
  name: kineticaoperator-controller-manager
  namespace: kinetica-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kineticaoperator-metrics-auth-rolebinding
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kineticaoperator-metrics-auth-role
subjects:
- kind: ServiceAccount
  name: kineticaoperator-controller-manager
  namespace: kinetica-system

---
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    control-plane: controller-manager
  name: kineticaoperator-controller-manager-metrics-service
  namespace: kinetica-system
spec:
  ports:
  - name: https
    port: 8443
    protocol: TCP
    targetPort: 8443
  selector:
    app.kubernetes.io/name: dboperator
    control-plane: controller-manager

---
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-webhook-service
  namespace: kinetica-system
spec:
  ports:
  - port: 443
    protocol: TCP
    targetPort: 9443
  selector:
    app.kubernetes.io/name: dboperator
    control-plane: controller-manager

---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    control-plane: controller-manager
  name: kineticaoperator-controller-manager
  namespace: kinetica-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: dboperator
      control-plane: controller-manager
  template:
    metadata:
      annotations:
        kubectl.kubernetes.io/default-container: manager
      labels:
        app.kubernetes.io/name: dboperator
        control-plane: controller-manager
    spec:
      containers:
      - args:
        - --metrics-bind-address=:8443
        - --leader-elect
        - --health-probe-bind-address=:8081
        - --metrics-cert-path=/tmp/k8s-metrics-server/metrics-certs
        - --webhook-cert-path=/tmp/k8s-webhook-server/serving-certs
        command:
        - /manager
        image: '{{- if .Values.dbOperator.image.repository -}}{{- .Values.dbOperator.image.repository
          -}}{{- else }}{{- .Values.dbOperator.image.registry -}}/{{- .Values.dbOperator.image.image
          -}}{{- end -}}{{- if (.Values.dbOperator.image.digest) -}} @{{- .Values.dbOperator.image.digest
          -}}{{- else -}}:{{- .Values.dbOperator.image.tag -}}{{- end -}}'
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8081
          initialDelaySeconds: 15
          periodSeconds: 20
        name: manager
        ports:
        - containerPort: 9443
          name: webhook-server
          protocol: TCP
        readinessProbe:
          httpGet:
            path: /readyz
            port: 8081
          initialDelaySeconds: 5
          periodSeconds: 10
        resources:
          limits:
            cpu: 500m
            memory: 128Mi
          requests:
            cpu: 10m
            memory: 64Mi
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
        volumeMounts:
        - mountPath: /tmp/k8s-metrics-server/metrics-certs
          name: metrics-certs
          readOnly: true
        - mountPath: /tmp/k8s-webhook-server/serving-certs
          name: webhook-certs
          readOnly: true
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      serviceAccountName: kineticaoperator-controller-manager
      terminationGracePeriodSeconds: 10
      volumes:
      - name: metrics-certs
        secret:
          items:
          - key: ca.crt
            path: ca.crt
          - key: tls.crt
            path: tls.crt
          - key: tls.key
            path: tls.key
          optional: false
          secretName: metrics-server-cert
      - name: webhook-certs
        secret:
          secretName: webhook-server-cert
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}

---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  annotations:
    helm.sh/hook: post-install,post-upgrade
    helm.sh/hook-weight: '1'
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-metrics-certs
  namespace: kinetica-system
spec:
  dnsNames:
  - kineticaoperator-controller-manager-metrics-service.kinetica-system.svc
  - kineticaoperator-controller-manager-metrics-service.kinetica-system.svc.cluster.local
  issuerRef:
    kind: Issuer
    name: kineticaoperator-selfsigned-issuer
  secretName: metrics-server-cert

---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  annotations:
    helm.sh/hook: post-install,post-upgrade
    helm.sh/hook-weight: '1'
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-serving-cert
  namespace: kinetica-system
spec:
  dnsNames:
  - kineticaoperator-webhook-service.kinetica-system.svc
  - kineticaoperator-webhook-service.kinetica-system.svc.cluster.local
  issuerRef:
    kind: Issuer
    name: kineticaoperator-selfsigned-issuer
  secretName: webhook-server-cert

---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  annotations:
    helm.sh/hook: post-install,post-upgrade
    helm.sh/hook-weight: '1'
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-selfsigned-issuer
  namespace: kinetica-system
spec:
  selfSigned: {}

---
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  annotations:
    cert-manager.io/inject-ca-from: kinetica-system/kineticaoperator-serving-cert
  name: kineticaoperator-mutating-webhook-configuration
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
webhooks:
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticacluster
  failurePolicy: Fail
  name: mkineticacluster-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusters
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticaclusteradmin
  failurePolicy: Fail
  name: mkineticaclusteradmin-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusteradmins
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticaclusterbackup
  failurePolicy: Fail
  name: mkineticaclusterbackup-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterbackups
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticaclusterelasticity
  failurePolicy: Fail
  name: mkineticaclusterelasticity-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterelasticities
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticaclusterresourcegroup
  failurePolicy: Fail
  name: mkineticaclusterresourcegroup-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterresourcegroups
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticaclusterrestore
  failurePolicy: Fail
  name: mkineticaclusterrestore-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterrestores
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticaclusterschema
  failurePolicy: Fail
  name: mkineticaclusterschema-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterschemas
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticagrant
  failurePolicy: Fail
  name: mkineticagrant-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticagrants
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticareleaseversion
  failurePolicy: Fail
  name: mkineticareleaseversion-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticareleaseversions
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticarole
  failurePolicy: Fail
  name: mkineticarole-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaroles
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticauser
  failurePolicy: Fail
  name: mkineticauser-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticausers
  sideEffects: None

---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  annotations:
    cert-manager.io/inject-ca-from: kinetica-system/kineticaoperator-serving-cert
  name: kineticaoperator-validating-webhook-configuration
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
webhooks:
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticacluster
  failurePolicy: Fail
  name: vkineticacluster-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusters
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticaclusteradmin
  failurePolicy: Fail
  name: vkineticaclusteradmin-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusteradmins
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticaclusterbackup
  failurePolicy: Fail
  name: vkineticaclusterbackup-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterbackups
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticaclusterelasticity
  failurePolicy: Fail
  name: vkineticaclusterelasticity-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterelasticities
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticaclusterresourcegroup
  failurePolicy: Fail
  name: vkineticaclusterresourcegroup-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterresourcegroups
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticaclusterrestore
  failurePolicy: Fail
  name: vkineticaclusterrestore-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterrestores
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticaclusterschema
  failurePolicy: Fail
  name: vkineticaclusterschema-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterschemas
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticagrant
  failurePolicy: Fail
  name: vkineticagrant-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticagrants
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticareleaseversion
  failurePolicy: Fail
  name: vkineticareleaseversion-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticareleaseversions
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticarole
  failurePolicy: Fail
  name: vkineticarole-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaroles
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticauser
  failurePolicy: Fail
  name: vkineticauser-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticausers
  sideEffects: None

{{- end }}