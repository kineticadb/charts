{{- define "kinetica-operators.saas-eks-dboperator-metering" }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/part-of: kinetica
  name: fluent-bit-config
  namespace: gpudb
data:
  {{- (tpl (.Files.Get "files/configmaps/saas-eks-dboperator-metering-fluent-bit-config.yaml") . | nindent 2)  }}

{{- end }}