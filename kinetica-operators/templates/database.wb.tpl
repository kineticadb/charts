{{- define "kinetica-operators.db-workbench" }}
---

apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: workbench
    app.kubernetes.io/component: ui
    app.kubernetes.io/instance: workbench
    app.kubernetes.io/part-of: kinetica
    "app.kubernetes.io/name": "kinetica-operators"
    "app.kubernetes.io/managed-by": "Helm"
    "app.kubernetes.io/instance": "{{ .Release.Name }}"
    "helm.sh/chart": '{{ include "kinetica-operators.chart" . }}'
  name: workbench-service-account
  namespace: "{{ .Values.kineticacluster.namespace }}"

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: workbench
  namespace: "{{ .Values.kineticacluster.namespace }}"
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
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
#- apiGroups:
#  - velero.io
#  resources:
#  - restores
#  verbs:
#  - get
#  - watch
#  - list
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
  name: workbench
  namespace: "{{ .Values.kineticacluster.namespace }}"
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: workbench
subjects:
- kind: ServiceAccount
  name: workbench-service-account
  namespace: "{{ .Values.kineticacluster.namespace }}"
{{- end }}
