{{- define "kinetica-operators.saas-eks-dboperator-namespaces" }}

---
apiVersion: v1
kind: Namespace
metadata:
  name: gpudb
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'

{{- end }}