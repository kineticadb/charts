{{- define "porter-operator.configMap" -}}
apiVersion: v1
data:
  controller_manager_config.yaml: |
    apiVersion: controller-runtime.sigs.k8s.io/v1alpha1
    kind: ControllerManagerConfig
    health:
      healthProbeBindAddress: :8081
    metrics:
      bindAddress: 127.0.0.1:8080
    webhook:
      port: 9443
    leaderElection:
      leaderElect: true
      resourceName: c58eb551.porter.sh
kind: ConfigMap
metadata:
  name: porter-operator-manager-config
  namespace: {{ .Values.porterOperator.namespace  }}
  labels:
    {{- include "porter-operator.labels" . | nindent 4 }}
{{- end -}}