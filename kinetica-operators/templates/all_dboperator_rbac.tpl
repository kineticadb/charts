{{- define "kinetica-operators.all-dboperator-rbac" }}

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kineticacluster-operator
  namespace: kinetica-system
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: manager-role
  namespace: gpudb
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
  - kineticaclusterschedules
  - kineticaclusterschemas
  - kineticaclusterupgrades
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
  - kineticaclusterschedules/status
  - kineticaclusterschemas/status
  - kineticaclusterupgrades/status
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
  name: leader-election-role
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
  namespace: gpudb
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: manager-role
subjects:
- kind: ServiceAccount
  name: kineticacluster-operator
  namespace: kinetica-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: leader-election-rolebinding
  namespace: kinetica-system
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: leader-election-role
subjects:
- kind: ServiceAccount
  name: default
  namespace: kinetica-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: manager-rolebinding
  namespace: kinetica-system
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: manager-role
subjects:
- kind: ServiceAccount
  name: kineticacluster-operator
  namespace: kinetica-system

---
apiVersion: v1
kind: Service
metadata:
{{ if .Values.controller.metricsService.annotations }}
  annotations:
{{ toYaml .Values.controller.metricsService.annotations | indent 4 }}
{{ end }}
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    control-plane: controller-manager
  name: controller-manager-metrics-service
  namespace: kinetica-system
spec:
  ports:
  - name: https
    port: 8443
    targetPort: https
  selector:
    control-plane: controller-manager

{{- end }}