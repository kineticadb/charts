{{- define "kinetica-operators.cacheStorageClass" }}
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: kinetica-db-diskcache
  labels:
    {{- include "kinetica-operators.labels" . | nindent 4 }}
provisioner: {{ .Values.dbOperator.storageClass.cache.provisioner | default .Values.defaultStorageProvisionerComputed }}
reclaimPolicy: {{ .Values.dbOperator.storageClass.cache.reclaimPolicy | default .Values.defaultReclaimPolicyComputed }}
volumeBindingMode: {{ .Values.dbOperator.storageClass.cache.volumeBindingMode | default .Values.defaultVolumeBindingModeComputed }}
{{- end }}