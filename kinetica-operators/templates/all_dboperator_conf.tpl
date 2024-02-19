{{- define "kinetica-operators.all-dboperator-conf" }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: gpudb-tmpl
  namespace: kinetica-system
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
data:
  {{ (.Files.Glob "files/configmaps/all-dboperator-conf-gpudb-tmpl.yaml").AsConfig }}

{{- end }}