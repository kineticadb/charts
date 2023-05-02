{{- define "kinetica-operators.wbOperatorInstallation" }}
apiVersion: porter.sh/v1
kind: Installation
metadata:
  labels:
    {{- include "kinetica-operators.labels" . | nindent 4 }}
    installVersion: {{ .Values.wbOperator.installVersion }}
  namespace: {{ .Values.wbOperator.namespace }}
  name: {{ include "kinetica-operators.fullname" . }}-wb-operator-install
spec:
  reference: "{{ .Values.wbOperator.image.repository }}:{{ .Values.wbOperator.image.tag | default .Chart.AppVersion }}"
  action: "install"
  agentConfig:
    volumeSize: '0'
  parameters:
    environment: {{ .Values.wbOperator.parameters.environmentComputed }}
{{- end}}