{{- define "kinetica-operators.all-wboperator-rbac" }}

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: workbench-operator-leader-election-role
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
  creationTimestamp:
  name: workbench-operator-manager-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- apiGroups:
  - ''
  resources:
  - clusterrolebindings
  - configmaps
  - events
  - namespaces
  - nodes
  - persistentvolumeclaims
  - persistentvolumes
  - pods
  - rolebindings
  - secrets
  - serviceaccounts
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
  - nodes
  - persistentvolumeclaims
  - persistentvolumes
  - pods
  - secrets
  - serviceaccounts
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
  - serviceaccounts/status
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
  - app.kinetica.com
  resources:
  - kineticaclusteradmins
  - kineticaclusterbackups
  - kineticaclusterrestores
  - kineticaclusters
  - kineticaclusterschedules
  - kineticaclusterupgrades
  - kineticacusers
  - kineticagrants
  - kineticaoperatorupgrades
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
  - kineticaclusteradmins
  - kineticaclusterbackups
  - kineticaclusterrestores
  - kineticaclusters
  - kineticaclusterschedules
  - kineticaclusterupgrades
  - kineticagrants
  - kineticaoperatorupgrades
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
  - kineticaclusteradmins/status
  - kineticaclusterbackups/status
  - kineticaclusterrestores/status
  - kineticaclusters/status
  - kineticaclusterschedules/status
  - kineticaclusterupgrades/status
  - kineticagrants/status
  - kineticaoperatorupgrades/status
  - kineticaroles/status
  - kineticausers/status
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
  - create
  - delete
  - escalate
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - rbac.authorization.k8s.io
  resources:
  - clusterrolebindings
  - rolebindings
  verbs:
  - create
  - delete
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
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - workbench.com.kinetica
  resources:
  - workbenches
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - workbench.com.kinetica
  resources:
  - workbenches
  - workbenchupgrades
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - workbench.com.kinetica
  resources:
  - workbenches/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - workbench.com.kinetica
  resources:
  - workbenches/status
  - workbenchupgrades/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - workbench.com.kinetica
  resources:
  - workbenchoperatorupgrades
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - workbench.com.kinetica
  resources:
  - workbenchoperatorupgrades/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - workbench.com.kinetica
  resources:
  - workbenchupgrades
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: workbench-operator-metrics-reader
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
  name: workbench-operator-proxy-role
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
  name: workbench-operator-leader-election-rolebinding
  namespace: kinetica-system
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: workbench-operator-leader-election-role
subjects:
- kind: ServiceAccount
  name: default
  namespace: kinetica-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: workbench-operator-manager-rolebinding
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: workbench-operator-manager-role
subjects:
- kind: ServiceAccount
  name: default
  namespace: kinetica-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: workbench-operator-proxy-rolebinding
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: workbench-operator-proxy-role
subjects:
- kind: ServiceAccount
  name: default
  namespace: kinetica-system

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
  name: workbench-operator-controller-manager-metrics-service
  namespace: kinetica-system
spec:
  ports:
  - name: https
    port: 8443
    targetPort: https
  selector:
    control-plane: controller-manager

{{- end }}