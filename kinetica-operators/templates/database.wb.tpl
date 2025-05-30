{{- define "kinetica-operators.db-workbench" }}
---

apiVersion: workbench.com.kinetica/v1
kind: Workbench
metadata:
  name: workbench
  namespace: {{.Values.kineticacluster.namespace}}
  labels:
    "app.kubernetes.io/name": "kinetica-operators"
    "app.kubernetes.io/managed-by": "Helm"
    "app.kubernetes.io/instance": "{{ .Release.Name }}"
    "helm.sh/chart": '{{ include "kinetica-operators.chart" . }}'
spec:
  {{- if eq (kindOf .Values.dbWorkbench.nodeSelector) "map" }}
  nodeSelector: {{ toYaml .Values.dbWorkbench.nodeSelector | nindent 8 }}
  {{- end }}
  fqdn: {{ .Values.dbWorkbench.fqdn | default "localhost" }}
  deploymentInfo: {{ .Values.dbWorkbench.deploymentInfo | toJson| squote  }}
  {{- if eq (kindOf .Values.dbWorkbench.letsEncrypt) "map" }}
  letsEncrypt:
    enabled: {{ .Values.dbWorkbench.letsEncrypt.enabled }}
    environment: {{  .Values.dbWorkbench.letsEncrypt.environment | default "staging"}}
  {{- end}}
  useHttps: {{ .Values.dbWorkbench.useHttps | default false}}
  image: "{{ .Values.dbWorkbench.image.repository }}:{{.Values.dbWorkbench.image.tag}}"
  storageClass: {{ .Values.kineticacluster.name }}-storageclass
---
{{- if eq .Values.dbWorkbench.fqdn "localhost" }}
{{- if and (eq (kindOf .Values.dbWorkbench.letsEncrypt) "map") .Values.dbWorkbench.letsEncrypt.enabled }}
apiVersion: v1
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUREekNDQWZlZ0F3SUJBZ0lVSEFoSjR4ZE1zNDA1SmFyek4zZ1pJWldGeEhRd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0ZERVNNQkFHQTFVRUF3d0piRzlqWVd4b2IzTjBNQjRYRFRJek1USXhNakEyTURBek1sb1hEVEkwTURFeApNVEEyTURBek1sb3dGREVTTUJBR0ExVUVBd3dKYkc5allXeG9iM04wTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGCkFBT0NBUThBTUlJQkNnS0NBUUVBdUQ5MmJSWEhvUjdMOGRBenQ1TFVCY0hwQ040MTFST1h2ZUtUSjdIRkp0bnQKOFhIR0dTUkgzcUVmRURuZmdzcjJpdmZrcGJyQ1FzWmZENTdnSG1OUTl0SWFHdFZEeDI2bzZiY3pjanVXSW9iWQp6VjJ3RWxjbFpOT1FjT0c3bmFVZFJ6Sm9VQ2ttcW5JYmdIdkZERUFOSHVHT2QxK0w5TWcySS9rRDM4UGkrVHRSClJoazV6STE1Q1g5eC9xaVQwdkVLQ3l0SVpadVFERk1XTTE5UXdWdGJ6TGw2a1M4TU00MGkrZzM5aVI0QkdacU0KSy9DWVZXVnhvSElsRFlKUldiZVNQKzFhaUpPVUQwQmMxVndXNXZ1WU00QVNGTXdYbUxFNEswNzdjNGd0T1I4cApXTDNwQXpCMC9Mdll5bGtQcDBIbm9pOFowNmh2RGg5cTR4b3NKdEpKSFFJREFRQUJvMWt3VnpBVUJnTlZIUkVFCkRUQUxnZ2xzYjJOaGJHaHZjM1F3Q3dZRFZSMFBCQVFEQWdlQU1CTUdBMVVkSlFRTU1Bb0dDQ3NHQVFVRkJ3TUIKTUIwR0ExVWREZ1FXQkJTcWNCRDFiKzl1RGNZZVJDeUdQcjUyYXVsYmV6QU5CZ2txaGtpRzl3MEJBUXNGQUFPQwpBUUVBYzVkdGw3MGtTd1JVdFo2NFpRZ3luZG9MdmZDbnFTR0xuSVVlY2xwcmh3d1RnYVlDWjdobUVmcE9HUEFnClRPQUpoUjB0eWhzNGxhbWYzcjdkYkJEQTJ6K3dTY2VCbjUycUNISmJUaTFQbDdWejRrcUxrd0YydHgxdE1nVDkKUkhhRURpTUlaSlhZTDl2NVZWaWFIOTh4QkUrdzhNY0dNbnZDcWcvdUpxS3NLOW8xYzMzV3kzYjJTVXlST0xLMwoveDl0aEk4UTJkVWdDbkh1bjJLMjFZZitvUFZTTERtTkxvRSt0b1hjUHo4TWdXRkRmVmRRUkJlZ0dsRk5EOWNwCnpKNVZKdU5DeFZsaXVJRnd1K3Y3WTFZN28yOVVnNmdJTmgyZEZpOVIyQUd2RC9wZm5qTG10WVlSNFNmQmY4dW8KSGZ0dlFUaVJobm1yNDY1TTZCZlR4b3BiNXc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
  tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2QUlCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktZd2dnU2lBZ0VBQW9JQkFRQzRQM1p0RmNlaEhzdngKMERPM2t0UUZ3ZWtJM2pYVkU1ZTk0cE1uc2NVbTJlM3hjY1laSkVmZW9SOFFPZCtDeXZhSzkrU2x1c0pDeGw4UApudUFlWTFEMjBob2ExVVBIYnFqcHR6TnlPNVlpaHRqTlhiQVNWeVZrMDVCdzRidWRwUjFITW1oUUtTYXFjaHVBCmU4VU1RQTBlNFk1M1g0djB5RFlqK1FQZncrTDVPMUZHR1RuTWpYa0pmM0grcUpQUzhRb0xLMGhsbTVBTVV4WXoKWDFEQlcxdk11WHFSTHd3empTTDZEZjJKSGdFWm1vd3I4SmhWWlhHZ2NpVU5nbEZadDVJLzdWcUlrNVFQUUZ6VgpYQmJtKzVnemdCSVV6QmVZc1RnclR2dHppQzA1SHlsWXZla0RNSFQ4dTlqS1dRK25RZWVpTHhuVHFHOE9IMnJqCkdpd20wa2tkQWdNQkFBRUNnZ0VBR3h2SFJseUdmemZEUlFSZm41cGNWSzZIcFhUZ1VjWHN0UlVCbHIwS3AyRTQKSjZhWVFYbTdrMDk4ZlF3dXpSVWt1aVNvQVJSZDRhcERNVTZzWmZ3eDNPYmp6Vi9rZFpMY0Ntc1lpQzJwTk5KSApVc3Yrakd4REJiYzFFTTY5cG4rMU01VUFrUTdFOEI0UzJ0QWJHV2JSSjJLRGJoL2lQVFU1OWdmODRHNzNWYmo2CjNTYmxzSFFXQWY1aEh5SmtLRWVSYkhMd3ordHlsZldJb3NqeVNybVBlVWRkMEVoYjFBMm9wWkJ0Y2xFWm9xNFIKMnVjQUJveTMrbmFKOE9CY2pGZHgyOHFSeVRqTjdkWnkyNVdmM0xMN0lQYUUzTzQ1UkdhY3llb25QOWpldEFNSwpTcGlFR1RiRE10a1VuZk5FRXZ2eG9uOXZKYk9IWFEyTVNGTVhGVXBPVndLQmdRRHRsQjdkWHVUSThqcnVqZDRQCnhVWWtsdEVabzVhNTZ0STZSOEZMR01Na2twNFUyV25HTUpQdEpaUkl4TEt2TTFUVDAzRmsrcndteUtJS1ovRUUKZkdsSGVRNjB0MHJuOU8xZWgzTGc2ZWR1eW43UGN1N2lzdnkxNks3QStURXFNVTNncmVsYkNkTVQ5ZWFNazNVKwpMTWlHMGZobzhiYmhzWFFLQWdyTjJ4VlR6d0tCZ1FER2lMMkFXbkYrUlBMS3lvQVFkNXNiZ2hHSmk5MXpYdDVXCkJrOXIza0VhVGxRVHlJUytMT0d5R2IxNDlYZXVCK1F3NFNZcmhWVWhnRTUzbkZ3N0JLQVNSaVh1R21Kdko5QjgKWmdnRng3RlBoZCtJdzEzbDlxSWxJM0lLdDBza25rcWh3emlGS3J5UFdoeER0R0NqYkJ4T21paGo4SXA1TllNSApNeFpDb29SVFV3S0JnRWQzSVBteVM5dnVrYStrMlVHaE5BSlpvN2kwcnVocUxLYi9Zck8yVlMweE5ZQk1EamRoCjhYMktxbHBoWU9hMjZETjREVW8wNmxnNFRoWVhRamI1UGFvVVRrb3FRTXdacnpXYVJRSkhHaWtIbkxIR2Z2bU8Kb2RvT2psTGFJdUh3UnQ3cE1hTURCNDJma0tTRXp1WFBEdHNQV2t3bk9iNFdaVE9GZmI2Q3dwMmRBb0dBTVB6TwpuWnd6Z3UrcVpRV0FnZyt4TXlGdUNGMTlvQmtaaldwek1HK2Y2c2pIRURhYkluM2FsdUtwRU82b3dFVnNOZTlvClJyYllvYktTS2d0bjZwd2lqei9GM2pHZWRrVUJ1YUJIZkgyZ3I3bWR4WlpIVmhYOFBtTzNvUk5ITkZybW1YR2QKUWFhZzdsSlN4Ulg5L25VUHF3bDR5K2d2a3ViMFZOTnpPNi8wTE1jQ2dZQWJ6UVdPY2M1Z0xuK0dxeWRnTTVWWAo3MU1RTkh3ZWU0b2QwazNJOHloK2hvUmc5N2xYT0poOU9xdW43cURmZnBTUG9OUlFScW5LVXlMQ0s2aHJ4ejJlCnF3Z0pIUmk1cTdxTW1nemJiRERkK1ZLUGM2Ym4weTBYT0ZmS2phYXVGYk5UNmRYYURuS3V0LzBZN2ErampjSmEKdWJUQUVCYUZFUldDUzlaRTQzWks2QT09Ci0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0K
kind: Secret
metadata:
  name: workbench-tls
  namespace: {{.Values.kineticacluster.namespace}}
type: kubernetes.io/tls
{{- end }}
{{- end }}
---
{{- end }}
