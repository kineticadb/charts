{{- define "kinetica-operators.all-dboperator-clusterrbac" }}

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: workbench
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kineticacluster-editor-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticacluster-viewer-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticaclusteradmin-editor-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticaclusteradmin-viewer-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticaclusterbackup-editor-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticaclusterbackup-viewer-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaclusterelasticity-editor-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
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
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaclusterelasticity-viewer-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
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
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaclusterresourcegroup-editor-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
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
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaclusterresourcegroup-viewer-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
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
kind: Role
metadata:
  name: kineticaclusterrestore-editor-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticaclusterrestore-viewer-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticaclusterschedule-editor-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticaclusterschedule-viewer-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaclusterschema-editor-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
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
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaclusterschema-viewer-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
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
kind: Role
metadata:
  name: kineticaclusterupgrade-editor-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticaclusterupgrade-viewer-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticagrant-editor-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticagrant-viewer-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticaoperatorupgrade-editor-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticaoperatorupgrade-viewer-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticareleaseversion-editor-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
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
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticareleaseversion-viewer-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
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
kind: Role
metadata:
  name: kineticarole-editor-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticarole-viewer-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticauser-editor-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
kind: Role
metadata:
  name: kineticauser-viewer-role
  namespace: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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

{{- end }}