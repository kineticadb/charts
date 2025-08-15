{{- define "kinetica-operators.tls-wb-secret" }}

---
apiVersion: v1
kind: Secret
metadata:
  name: kinetica-tls
  namespace: {{ .Values.kineticacluster.namespace }}
type: kubernetes.io/tls
data:
  tls.crt: {{ .Values.tlsTermination.workbench.certificate }}
  tls.key: {{ .Values.tlsTermination.workbench.privateKey }}

{{- end }}
