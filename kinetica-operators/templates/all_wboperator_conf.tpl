{{- define "kinetica-operators.all-wboperator-conf" }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: workbench-tmpl
  namespace: kinetica-system
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
data:
  {{ (.Files.Glob "files/configmaps/all-wboperator-conf-workbench-tmpl.yaml").AsConfig }}

{{- end }}