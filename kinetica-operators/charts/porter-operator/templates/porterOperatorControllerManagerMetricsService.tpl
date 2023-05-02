{{- define "porter-operator.metricsService" }}
apiVersion: v1
kind: Service
metadata:
  labels:
    {{- include "porter-operator.labels" . | nindent 4 }}
    control-plane: controller-manager
  name: porter-operator-controller-manager-metrics-service
  namespace: {{ .Values.porterOperator.namespace }}
spec:
  ports:
    - name: https
      port: !!int {{ .Values.porterOperator.proxy.containerPort }}
      targetPort: https
  selector:
    control-plane: controller-manager
{{- end }}