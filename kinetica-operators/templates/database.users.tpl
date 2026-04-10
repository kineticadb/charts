
{{- define "kinetica-operators.db-admin-user" }}

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
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-delete-script
  namespace: {{ .Release.Namespace }}
  annotations:
    "helm.sh/hook": pre-delete
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
    "helm.sh/hook-weight": "-10"
data:
  delete-script.sh: |
    #!/bin/sh
    NS="{{ .Values.kineticacluster.namespace }}"
    ku="$(kubectl -n "$NS" get ku -l app.kubernetes.io/name=kinetica-operators -o name 2>/dev/null)"
    if [ -n "$ku" ]; then
      op="$(kubectl -n "{{ .Release.Namespace }}" get deployments kineticaoperator-controller-manager -o name 2>/dev/null)"
      if [ -n "$op" ]; then
        kubectl -n "{{ .Release.Namespace }}" scale "$op" --replicas=0
      fi
      kubectl -n "$NS" patch $ku -p '{"metadata":{"finalizers":null}}' --type=merge
      kubectl -n "$NS" delete $ku
      kubectl -n "$NS" delete kineticagrants -l app.kubernetes.io/name=kinetica-operators --ignore-not-found
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
      securityContext:
        fsGroup: 2000
        runAsGroup: 3000
        runAsNonRoot: true
        runAsUser: 65432
      volumes:
      - name: script-volume
        configMap:
          name: {{ .Release.Name }}-delete-script
      containers:
      - name: kubectl
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          seccompProfile:
            type: RuntimeDefault
        image: "{{ include "kinetica-operators.image" (dict "registry" (.Values.kineticacluster.supportingImages.busybox.registry | default .Values.global.image.registry) "repository" .Values.kineticacluster.supportingImages.busybox.repository "tag" .Values.kineticacluster.supportingImages.busybox.tag) }}"
        command: ["/bin/sh"]
        args: ["/mnt/scripts/delete-script.sh"]
        volumeMounts:
        - name: script-volume
          mountPath: /mnt/scripts
      restartPolicy: Never
{{- end }}
