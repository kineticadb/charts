{{- define "kinetica-operators.crds" }}

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: '{{ .Release.Name }}-crd-manager'
  namespace: '{{ .Release.Namespace }}'
  annotations:
    helm.sh/hook: pre-install,pre-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
    helm.sh/hook-weight: '-10'

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: '{{ .Release.Name }}-crd-manager'
  annotations:
    helm.sh/hook: pre-install,pre-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
    helm.sh/hook-weight: '-10'
rules:
- apiGroups: ["apiextensions.k8s.io"]
  resources: ["customresourcedefinitions"]
  verbs: ["get", "update"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: '{{ .Release.Name }}-crd-manager'
  annotations:
    helm.sh/hook: pre-install,pre-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
    helm.sh/hook-weight: '-10'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: '{{ .Release.Name }}-crd-manager'
subjects:
- kind: ServiceAccount
  name: '{{ .Release.Name }}-crd-manager'
  namespace: '{{ .Release.Namespace }}'

---
apiVersion: batch/v1
kind: Job
metadata:
  name: '{{ .Release.Name }}-upsert-kinetica-crds'
  namespace: '{{ .Release.Namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  annotations:
    helm.sh/hook: pre-install,pre-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
    helm.sh/hook-weight: '-5'
spec:
  template:
    spec:
      serviceAccountName: '{{ .Release.Name }}-crd-manager'
      containers:
      - name: upsert-kinetica-crds-job
        image: "{{ .Values.upsertKineticaCrds.image.repository }}:{{ .Values.upsertKineticaCrds.image.tag }}"
      restartPolicy: Never

{{- end }}
