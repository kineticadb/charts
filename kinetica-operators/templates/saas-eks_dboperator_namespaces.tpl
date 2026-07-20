{{- define "kinetica-operators.saas-eks-dboperator-namespaces" }}

{{ if .Values.createNamespaces }}
{{ if not (lookup "v1" "Namespace" "" "cert-manager") }}
---
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    helm.sh/hook: pre-install
    helm.sh/hook-weight: '-15'
    helm.sh/resource-policy: keep
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/part-of: kinetica
  name: cert-manager
{{ end }}
{{ end }}

{{ if .Values.createNamespaces }}
{{ if not (lookup "v1" "Namespace" "" .Values.kineticacluster.namespace) }}
---
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    helm.sh/hook: pre-install
    helm.sh/hook-weight: '-15'
    helm.sh/resource-policy: keep
  name: '{{ .Values.kineticacluster.namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
{{ end }}
{{ end }}

{{ if .Values.createNamespaces }}
{{ if not (lookup "v1" "Namespace" "" "nginx") }}
---
apiVersion: v1
kind: Namespace
metadata:
  name: nginx
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
{{ end }}
{{ end }}

---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: '{{ .Values.kineticacluster.namespace }}'
  name: '{{ .Values.kineticacluster.namespace }}-stats'
  namespace: '{{ .Values.kineticacluster.namespace }}'

---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: workbench
  name: workbench-service-account
  namespace: '{{ .Values.kineticacluster.namespace }}'

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: '{{ .Values.kineticacluster.namespace }}'
  name: '{{ .Values.kineticacluster.namespace }}'
  namespace: '{{ .Values.kineticacluster.namespace }}'
rules:
- apiGroups:
  - ''
  resources:
  - configmaps
  - events
  - pods
  - pods/status
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
  - apps
  resources:
  - statefulsets
  - statefulsets/status
  verbs:
  - get
  - list
  - watch

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: '{{ .Values.kineticacluster.namespace }}'
  name: '{{ .Values.kineticacluster.namespace }}-stats'
  namespace: '{{ .Values.kineticacluster.namespace }}'
rules:
- apiGroups:
  - ''
  resources:
  - pods
  verbs:
  - get
  - list
  - watch

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: workbench
  name: workbench
  namespace: '{{ .Values.kineticacluster.namespace }}'
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
  - create
  - update
  - patch
  - delete
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

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: '{{ .Values.kineticacluster.namespace }}'
  name: '{{ .Values.kineticacluster.namespace }}'
  namespace: '{{ .Values.kineticacluster.namespace }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: '{{ .Values.kineticacluster.namespace }}'
subjects:
- kind: ServiceAccount
  name: default
  namespace: '{{ .Values.kineticacluster.namespace }}'

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: '{{ .Values.kineticacluster.namespace }}'
  name: '{{ .Values.kineticacluster.namespace }}-stats'
  namespace: '{{ .Values.kineticacluster.namespace }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: '{{ .Values.kineticacluster.namespace }}-stats'
subjects:
- kind: ServiceAccount
  name: '{{ .Values.kineticacluster.namespace }}-stats'
  namespace: '{{ .Values.kineticacluster.namespace }}'

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: workbench
  name: workbench
  namespace: '{{ .Values.kineticacluster.namespace }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: workbench
subjects:
- kind: ServiceAccount
  name: workbench-service-account
  namespace: '{{ .Values.kineticacluster.namespace }}'

{{- end }}