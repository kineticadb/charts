{{- define "kinetica-operators.aks-dboperator-operator" }}

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
kind: Role
metadata:
  name: kineticaoperator-manager-role
  namespace: kinetica-system
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
  - secrets
  verbs:
  - get
  - list
- apiGroups:
  - ''
  resources:
  - events
  verbs:
  - create
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
  - patch
  - update

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
kind: ConfigMap
metadata:
  name: kineticaoperator-config-map
  namespace: kinetica-system
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
data:
  {{ (.Files.Glob "files/configmaps/aks-dboperator-operator-kineticaoperator-config-map.yaml").AsConfig }}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: kineticaoperator-controller-manager
    app.kubernetes.io/managed-by: Porter
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: gpudb
    app.kinetica.com/pool: infra
    app.kubernetes.io/component: db-operator
    app.kubernetes.io/part-of: kinetica
    component: kineticaoperator-controller-manager
    control-plane: controller-manager
  name: kineticaoperator-controller-manager
  namespace: kinetica-system
spec:
  replicas: 1
  selector:
    matchLabels:
      control-plane: controller-manager
  template:
    metadata:
      labels:
        app: gpudb
        app.kinetica.com/pool: infra
        app.kubernetes.io/component: db-operator
        app.kubernetes.io/name: kineticaoperator-controller-manager
        app.kubernetes.io/part-of: kinetica
        azure.workload.identity/use: 'true'
        component: kineticaoperator-controller-manager
        control-plane: controller-manager
    spec:
      containers:
      - args:
        - --secure-listen-address=0.0.0.0:8443
        - --upstream=http://127.0.0.1:8080/
        - --v=0
        image: '{{ .Values.kubeRbacProxy.image.repository }}:{{ .Values.kubeRbacProxy.image.tag
          }}'
        imagePullPolicy: IfNotPresent
        name: kube-rbac-proxy
        ports:
        - containerPort: 8443
          name: https
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
      - args:
        - --metrics-addr=127.0.0.1:8080
        - --enable-leader-election
        - --zap-log-level=error
        command:
        - /manager
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: POD_SERVICE_ACCOUNT
          valueFrom:
            fieldRef:
              fieldPath: spec.serviceAccountName
        image: '{{- if .Values.dbOperator.image.repository -}}{{- .Values.dbOperator.image.repository
          -}}{{- else }}{{- .Values.dbOperator.image.registry -}}/{{- .Values.dbOperator.image.image
          -}}{{- end -}}{{- if (.Values.dbOperator.image.digest) -}} @{{- .Values.dbOperator.image.digest
          -}}{{- else -}}:{{- .Values.dbOperator.image.tag -}}{{- end -}}'
        imagePullPolicy: IfNotPresent
        name: manager
        resources:
          limits:
            cpu: 250m
            memory: 1Gi
          requests:
            cpu: 100m
            memory: 256Mi
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
        volumeMounts:
        - mountPath: /etc/config/
          name: gpudb-tmpl
        - mountPath: /etc/manager/manager-config
          name: kineticaoperator-config-map
      securityContext:
        fsGroup: 2000
        runAsGroup: 3000
        runAsNonRoot: true
        runAsUser: 65432
      serviceAccountName: kineticacluster-operator
      terminationGracePeriodSeconds: 10
      volumes:
      - configMap:
          name: gpudb-tmpl
        name: gpudb-tmpl
      - configMap:
          name: kineticaoperator-config-map
        name: kineticaoperator-config-map
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

{{- end }}