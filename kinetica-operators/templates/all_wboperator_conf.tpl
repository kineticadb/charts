{{- define "kinetica-operators.all-wboperator-conf" }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: workbench-tmpl
  namespace: kinetica-system
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
data:
  {{ (.Files.Glob "files/configmaps/all-wboperator-conf-workbench-tmpl.yaml").AsConfig }}

{{- end }}