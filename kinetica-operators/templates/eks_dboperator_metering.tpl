{{- define "kinetica-operators.eks-dboperator-metering" }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/part-of: kinetica
  name: fluent-bit-config
  namespace: gpudb
data:
  {{- (tpl (.Files.Get "files/configmaps/eks-dboperator-metering-fluent-bit-config.yaml") . | nindent 2)  }}

{{- end }}