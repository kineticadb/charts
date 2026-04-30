
{{- define "kinetica-operators.db-admin-user" }}

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
    # Namespace-wide cleanup of user-management CRs. Selecting on
    # app.kubernetes.io/name=kinetica-operators only catches what the
    # chart created — workbench- and API-created KineticaUser/Grant/Role
    # resources are unlabeled and would survive uninstall, leaving
    # finalizer-blocked CRs that wedge the namespace. Sweep the whole
    # cluster namespace; KineticaCluster itself is Helm-tracked from the
    # subchart and handled by Helm's release teardown after this hook.
    NS="{{ .Values.kineticacluster.namespace }}"
    ku="$(kubectl -n "$NS" get ku -o name 2>/dev/null)"
    kg="$(kubectl -n "$NS" get kineticagrants -o name 2>/dev/null)"
    kr="$(kubectl -n "$NS" get kineticaroles -o name 2>/dev/null)"
    if [ -n "$ku" ] || [ -n "$kg" ] || [ -n "$kr" ]; then
      op="$(kubectl -n "{{ .Release.Namespace }}" get deployments kineticaoperator-controller-manager -o name 2>/dev/null)"
      if [ -n "$op" ]; then
        kubectl -n "{{ .Release.Namespace }}" scale "$op" --replicas=0
      fi
      if [ -n "$ku" ]; then
        kubectl -n "$NS" patch $ku -p '{"metadata":{"finalizers":null}}' --type=merge
        kubectl -n "$NS" delete $ku --ignore-not-found
      fi
      if [ -n "$kg" ]; then
        kubectl -n "$NS" patch $kg -p '{"metadata":{"finalizers":null}}' --type=merge
        kubectl -n "$NS" delete $kg --ignore-not-found
      fi
      if [ -n "$kr" ]; then
        kubectl -n "$NS" patch $kr -p '{"metadata":{"finalizers":null}}' --type=merge
        kubectl -n "$NS" delete $kr --ignore-not-found
      fi
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
