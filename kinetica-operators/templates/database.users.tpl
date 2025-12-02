
{{- define "kinetica-operators.db-admin-user" }}


---
apiVersion: v1
stringData:
  password: {{ required "Password for Admin User is required, use --set dbAdminUser.password=your_password" .Values.dbAdminUser.password }}
kind: Secret
metadata: 
  name: admin-pwd
  namespace: {{ .Values.kineticacluster.namespace }}
  labels:
    "app.kubernetes.io/name": "kinetica-operators"
    "app.kubernetes.io/managed-by": "Helm"
    "app.kubernetes.io/instance": "{{ .Release.Name }}"
    "helm.sh/chart": '{{ include "kinetica-operators.chart" . }}'
type: Opaque
---
apiVersion: app.kinetica.com/v1
kind: KineticaUser
metadata:
  name: {{ .Values.dbAdminUser.name }}
  namespace: {{ .Values.kineticacluster.namespace }}
  labels:
    "app.kubernetes.io/name": "kinetica-operators"
    "app.kubernetes.io/managed-by": "Helm"
    "app.kubernetes.io/instance": "{{ .Release.Name }}"
    "helm.sh/chart": '{{ include "kinetica-operators.chart" . }}'
spec:
  ringName: {{ .Values.kineticacluster.name }}
  uid: {{ .Values.dbAdminUser.name }}
  action: upsert
  reveal: true
  upsert:
    givenName: Admin
    displayName: "Admin Account"
    lastName: Account
    passwordSecret: admin-pwd
    userPrincipalName: admin@acct.com
---
apiVersion: app.kinetica.com/v1
kind: KineticaGrant
metadata:
  name: global-admin-system-admin
  namespace: {{ .Values.kineticacluster.namespace }}
  labels:
    "app.kubernetes.io/name": "kinetica-operators"
    "app.kubernetes.io/managed-by": "Helm"
    "app.kubernetes.io/instance": "{{ .Release.Name }}"
    "helm.sh/chart": '{{ include "kinetica-operators.chart" . }}'
spec:
  ringName: {{ .Values.kineticacluster.name }}
  addGrantPermissionRequest:
    systemPermission:
      name: "global_admins"
      permission: "system_admin"
---
apiVersion: app.kinetica.com/v1
kind: KineticaGrant
metadata:
  name: "{{ .Values.dbAdminUser.name }}-global-admin-create"
  namespace: {{ .Values.kineticacluster.namespace }}
spec:
  ringName: {{ .Values.kineticacluster.name }}
  addGrantRoleRequest:
    role: global_admins
    member: {{ .Values.dbAdminUser.name }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-delete-script
  namespace: {{ .Release.Namespace }}
data:
  delete-script.sh: |  
    #!/bin/sh
    ku="$(kubectl -n "{{ .Values.kineticacluster.namespace }}" get ku -l app.kubernetes.io/name=kinetica-operators -o name 2>/dev/null)"
    if [ -n "$ku" ]; then
      op="$(kubectl -n "{{ .Release.Namespace }}" get deployments kineticaoperator-controller-manager -o name 2>/dev/null)"
      if [ -n "$op" ]; then
        kubectl -n "{{ .Release.Namespace }}" scale "$op" --replicas=0
      fi
      kubectl -n "{{ .Values.kineticacluster.namespace }}" patch "$ku" -p '{"metadata":{"finalizers":null}}' --type=merge
      kubectl -n "{{ .Values.kineticacluster.namespace }}" delete KineticaUser "{{ .Values.dbAdminUser.name }}"
    fi
    exit 0
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Release.Name }}-pre-delete-job
  namespace: {{ .Release.Namespace }}
  labels:
    "app.kubernetes.io/name": "kinetica-operators"
    "app.kubernetes.io/managed-by": "Helm"
    "app.kubernetes.io/instance": "{{ .Release.Name }}"
    "helm.sh/chart": '{{ include "kinetica-operators.chart" . }}'
  annotations:
    "helm.sh/hook": pre-delete
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
    "helm.sh/hook-weight": "-5"
spec:
  template:
    spec:
      serviceAccount: kineticacluster-operator
      serviceAccountName: kineticacluster-operator
      volumes:
      - name: script-volume
        configMap:
          name: {{ .Release.Name }}-delete-script
      containers:
      - name: kubectl
        securityContext:
          runAsNonRoot: true
          runAsUser: 1000
          allowPrivilegeEscalation: false
        image: "{{ .Values.kineticacluster.supportingImages.busybox.registry }}/{{ .Values.kineticacluster.supportingImages.busybox.repository }}:{{ .Values.kineticacluster.supportingImages.busybox.tag }}"
        command: ["/bin/sh"]
        args: ["/mnt/scripts/delete-script.sh"]
        volumeMounts:
        - name: script-volume
          mountPath: /mnt/scripts
      restartPolicy: Never
{{- end }}
