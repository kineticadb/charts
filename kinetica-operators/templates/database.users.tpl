
{{- define "kinetica-operators.db-admin-user" }}


---
apiVersion: v1
stringData:
  password: {{ required "Password for Admin User is required, use --set dbAdminUser.password=your_password" .Values.dbAdminUser.password }}
kind: Secret
metadata: 
  name: admin-pwd
  namespace: {{ .Values.db.namespace }}
type: Opaque
---
apiVersion: app.kinetica.com/v1
kind: KineticaUser
metadata:
  name: {{ .Values.dbAdminUser.name }}
  namespace: {{ .Values.db.namespace }}
spec:
  ringName: {{ .Values.db.name }}
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
  namespace: {{ .Values.db.namespace }}
spec:
  ringName: {{ .Values.db.name }}
  addGrantPermissionRequest:
    systemPermission:
      name: "global_admins"
      permission: "system_admin"
---
apiVersion: app.kinetica.com/v1
kind: KineticaGrant
metadata:
  name: "{{ .Values.dbAdminUser.name }}-global-admin-create"
  namespace: {{ .Values.db.namespace }}
spec:
  ringName: {{ .Values.db.name }}
  addGrantRoleRequest:
    role: global_admins
    member: {{ .Values.dbAdminUser.name }}
---

apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Release.Name }}-pre-delete-job
  namespace: {{ .Values.db.namespace }}
  annotations:
    "helm.sh/hook": pre-delete
    "helm.sh/hook-delete-policy": hook-succeeded
    "helm.sh/hook-weight": "-5"
spec:
  template:
    spec:
      containers:
      - name: kubectl
        image: bitnami/kubectl:latest  
        command: ["kubectl"]
        args: ["-n", "{{ .Values.db.namespace }}","delete", "KineticaUser", "{{ .Values.dbAdminUser.name }}" ,"--ignore-not-found=true"] 
      restartPolicy: Never
{{- end }}
