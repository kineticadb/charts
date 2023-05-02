{{- define "kinetica-operators.dbPersistStorageClass" }}
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: kinetica-db-persist
  labels:
    {{- include "kinetica-operators.labels" . | nindent 4 }}
provisioner: {{ .Values.dbOperator.storageClass.persist.provisioner | default .Values.defaultStorageProvisionerComputed }}
reclaimPolicy: {{ .Values.dbOperator.storageClass.persist.reclaimPolicy | default .Values.defaultReclaimPolicyComputed }}
volumeBindingMode: {{ .Values.dbOperator.storageClass.persist.volumeBindingMode | default .Values.defaultVolumeBindingModeComputed }}
{{- end }}