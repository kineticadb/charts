{{- define "kinetica-operators.wbPersistStorageClass" }}
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: kinetica-wb-persist
  labels:
    {{- include "kinetica-operators.labels" . | nindent 4 }}
provisioner: {{ .Values.wbOperator.storageClass.persist.provisioner | default .Values.defaultStorageProvisionerComputed }}
reclaimPolicy: {{ .Values.wbOperator.storageClass.persist.reclaimPolicy | default .Values.defaultReclaimPolicyComputed }}
volumeBindingMode: {{ .Values.wbOperator.storageClass.persist.volumeBindingMode | default .Values.defaultVolumeBindingModeComputed }}
{{- end }}