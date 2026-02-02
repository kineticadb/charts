{{- define "kinetica-operators.all-dboperator-conf" }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: gpudb-tmpl
  namespace: '{{ .Release.Namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
data:
  {{ (.Files.Glob "files/configmaps/all-dboperator-conf-gpudb-tmpl.yaml").AsConfig }}

{{- end }}