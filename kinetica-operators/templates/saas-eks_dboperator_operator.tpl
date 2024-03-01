{{- define "kinetica-operators.saas-eks-dboperator-operator" }}

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kineticaoperator-kineticacluster-operator
  namespace: kinetica-system
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kineticaoperator-leader-election-role
  namespace: kinetica-system
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  - configmaps/status
  verbs:
  - get
  - update
  - patch
- apiGroups:
  - ''
  resources:
  - events
  verbs:
  - create

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kineticaoperator-kineticacluster-editor-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticacluster-viewer-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticaclusteradmin-editor-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticaclusteradmin-viewer-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticaclusterbackup-editor-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticaclusterbackup-viewer-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticaclusterelasticity-editor-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticaclusterelasticity-viewer-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticaclusterresourcegroup-editor-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticaclusterresourcegroup-viewer-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticaclusterrestore-editor-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticaclusterrestore-viewer-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticaclusterschedule-editor-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterschedules
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
  - kineticaclusterschedules/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kineticaoperator-kineticaclusterschedule-viewer-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterschedules
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterschedules/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kineticaoperator-kineticaclusterschema-editor-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticaclusterschema-viewer-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticaclusterupgrade-editor-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterupgrades
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
  - kineticaclusterupgrades/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kineticaoperator-kineticaclusterupgrade-viewer-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterupgrades
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterupgrades/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kineticaoperator-kineticagrant-editor-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticagrant-viewer-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticaoperatorupgrade-editor-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaoperatorupgrades
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
  - kineticaoperatorupgrades/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kineticaoperator-kineticaoperatorupgrade-viewer-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaoperatorupgrades
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaoperatorupgrades/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kineticaoperator-kineticareleaseversion-editor-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticareleaseversion-viewer-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticarole-editor-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticarole-viewer-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticauser-editor-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  name: kineticaoperator-kineticauser-viewer-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
  creationTimestamp:
  name: kineticaoperator-manager-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- apiGroups:
  - ''
  resources:
  - configmaps
  - events
  - namespaces
  - nodes
  - persistentvolumeclaims
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
  - configmaps
  - events
  - namespaces
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
  - configmaps
  - namespaces
  - secrets
  - serviceaccounts
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
  - configmaps/status
  - events/status
  - namespaces/status
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
  - persistentvolumes
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - admissionregistration.k8s.io
  resources:
  - mutatingwebhookconfigurations
  - validatingwebhookconfigurations
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - apiextensions.k8s.io
  resources:
  - customresourcedefinitions
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - apiextensions.k8s.io/v1
  resources:
  - customresourcedefinitions
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
  - kineticacluster
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
  - kineticaclusteradmins/finalizers
  verbs:
  - update
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusteradmins/status
  verbs:
  - get
  - patch
  - update
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
  - kineticaclusterbackups/finalizers
  verbs:
  - update
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterbackups/status
  verbs:
  - get
  - patch
  - update
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
  - patch
  - update
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
  - patch
  - update
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
  - patch
  - update
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
  - kineticaclusters/finalizers
  verbs:
  - update
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusters/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterschedules
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
  - kineticaclusterschedules/status
  verbs:
  - get
  - patch
  - update
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
  - patch
  - update
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusterupgrades
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
  - kineticaclusterupgrades/status
  verbs:
  - get
  - patch
  - update
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
  - patch
  - update
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaoperatorupgrades
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
  - kineticaoperatorupgrades/status
  verbs:
  - get
  - patch
  - update
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
  - patch
  - update
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
  - apps
  resources:
  - deployments
  - replicasets
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
  - replicasets/status
  verbs:
  - get
  - patch
  - update
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
  - cert-manager.io
  resources:
  - certificates
  - clusterissuers
  - issuers
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
  - opentelemetry.io
  resources:
  - opentelemetrycollectors
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - opentelemetry.io
  resources:
  - opentelemetrycollectors/finalizers
  - opentelemetrycollectors/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - porter.sh
  resources:
  - installations
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - porter.sh
  resources:
  - installations/status
  verbs:
  - get
  - watch
- apiGroups:
  - rbac.authorization.k8s.io
  resources:
  - clusterrolebindings
  - clusterroles
  - rolebindings
  - roles
  verbs:
  - bind
  - create
  - delete
  - escalate
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - rbac.authorization.k8s.io/v1
  resources:
  - clusterrolebindings
  - clusterroles
  - rolebindings
  - roles
  verbs:
  - create
  - delete
  - escalate
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - rbac.authorization.k8s.io/v1beta1
  resources:
  - clusterrolebindings
  - clusterroles
  - rolebindings
  - roles
  verbs:
  - create
  - delete
  - escalate
  - get
  - list
  - patch
  - update
  - watch
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
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - velero.io
  resources:
  - deletebackuprequests
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
  - restores/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - velero.io
  resources:
  - schedules
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
  - schedules/status
  verbs:
  - get
  - patch
  - update

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kineticaoperator-metrics-reader
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- nonResourceURLs:
  - /metrics
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kineticaoperator-proxy-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: RoleBinding
metadata:
  name: kineticaoperator-leader-election-rolebinding
  namespace: kinetica-system
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kineticaoperator-leader-election-role
subjects:
- kind: ServiceAccount
  name: default
  namespace: kinetica-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kineticaoperator-manager-rolebinding
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kineticaoperator-manager-role
subjects:
- kind: ServiceAccount
  name: kineticaoperator-kineticacluster-operator
  namespace: kinetica-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kineticaoperator-proxy-rolebinding
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kineticaoperator-proxy-role
subjects:
- kind: ServiceAccount
  name: default
  namespace: kinetica-system

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kineticaoperator-config-map
  namespace: kinetica-system
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
data:
  {{ (.Files.Glob "files/configmaps/saas-eks-dboperator-operator-kineticaoperator-config-map.yaml").AsConfig }}

---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    control-plane: controller-manager
  name: kineticaoperator-controller-manager-metrics-service
  namespace: kinetica-system
spec:
  ports:
  - name: https
    port: 8443
    targetPort: https
  selector:
    control-plane: controller-manager

---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: gpudb
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    app.kinetica.com/pool: infra
    app.kubernetes.io/component: db-operator
    app.kubernetes.io/managed-by: Porter
    app.kubernetes.io/name: kineticaoperator-controller-manager
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
      serviceAccountName: kineticaoperator-kineticacluster-operator
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