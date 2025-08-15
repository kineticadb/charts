{{- define "kinetica-operators.tls-db-secret" }}

---
apiVersion: v1
kind: Secret
metadata:
  name: kinetica-tls
  namespace: {{ .Values.kineticacluster.namespace }} 
type: kubernetes.io/tls
data:
  tls.crt: {{ .Values.tlsTermination.database.certificate }}
  tls.key: {{ .Values.tlsTermination.database.privateKey }}

{{- end }}
