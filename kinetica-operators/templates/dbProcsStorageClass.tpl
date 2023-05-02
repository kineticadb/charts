{{- define "kinetica-operators.dbProcsStorageClass" }}
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: kinetica-db-procs
  labels:
    {{- include "kinetica-operators.labels" . | nindent 4 }}
provisioner: {{ .Values.dbOperator.storageClass.procs.provisioner | default .Values.defaultStorageProvisionerComputed }}
reclaimPolicy: {{ .Values.dbOperator.storageClass.procs.reclaimPolicy | default .Values.defaultReclaimPolicyComputed }}
volumeBindingMode: {{ .Values.dbOperator.storageClass.procs.volumeBindingMode | default .Values.defaultVolumeBindingModeComputed }}
{{- end }}