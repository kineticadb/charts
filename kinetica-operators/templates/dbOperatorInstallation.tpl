{{- define "kinetica-operators.dbOperatorInstallation" }}
apiVersion: porter.sh/v1
kind: Installation
metadata:
  labels:
    {{- include "kinetica-operators.labels" . | nindent 4 }}
    installVersion: {{ .Values.dbOperator.installVersion }}
  namespace: {{ .Values.dbOperator.namespace }}
  name: {{ include "kinetica-operators.fullname" . }}-operator-install
spec:
  reference: "{{ .Values.dbOperator.image.repository}}:{{ .Values.dbOperator.image.tag | default (print "v" .Chart.AppVersion) }}"
  action: "install"
  agentConfig:
    volumeSize: '0'
  parameters:
    environment: {{ .Values.dbOperator.parameters.environmentComputed }}
    storageclass: {{ .Values.dbOperator.parameters.storageClass | default .Values.defaultStorageClassComputed }}
    {{ include "kinetica-operators.versions" . | nindent 4 }}
{{- end }}