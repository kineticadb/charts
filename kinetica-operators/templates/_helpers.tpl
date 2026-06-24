{{/*
Expand the name of the chart.
*/}}
{{- define "kinetica-operators.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kinetica-operators.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kinetica-operators.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kinetica-operators.labels" -}}
helm.sh/chart: {{ include "kinetica-operators.chart" . }}
{{ include "kinetica-operators.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kinetica-operators.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kinetica-operators.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kinetica-operators.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kinetica-operators.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Construct a full image reference: registry/repository:tag or registry/repository@digest
Usage: {{ include "kinetica-operators.image" (dict "registry" .Values.global.image.registry "repository" .Values.X.image.repository "tag" .Values.X.image.tag "digest" .Values.X.image.digest) }}
*/}}
{{- define "kinetica-operators.image" -}}
{{- $registry := .registry | default "" -}}
{{- $repository := .repository -}}
{{- $tag := .tag | default "" -}}
{{- $digest := .digest | default "" -}}
{{- if $registry -}}{{ $registry }}/{{- end -}}
{{- $repository -}}
{{- if $digest -}}@{{- $digest -}}{{- else if $tag -}}:{{- $tag -}}{{- end -}}
{{- end -}}

{{/*
Resolve license value from a pre-created Kubernetes Secret.
Requires kineticacluster.gpudbCluster.licenseSecretName to be set.
The secret must contain a 'license' key.
During helm template (dry-run), lookup returns empty — a placeholder is used
and the post-install hook patches the real license from the mounted secret.
Usage: {{ include "kinetica-operators.resolveLicense" (dict "Values" .Values "Release" .Release) }}
*/}}
{{- define "kinetica-operators.resolveLicense" -}}
{{- $namespace := .Values.kineticacluster.namespace | default .Release.Namespace -}}
{{- $secretName := .Values.kineticacluster.gpudbCluster.licenseSecretName | default "" -}}
{{- if eq $secretName "" -}}
  {{- fail "kineticacluster.gpudbCluster.licenseSecretName is required. Create a secret with a 'license' key and set this value to the secret name. Example: kubectl create secret generic my-license-secret --from-literal=license=YOUR_LICENSE -n gpudb" -}}
{{- end -}}
{{- $secret := lookup "v1" "Secret" $namespace $secretName -}}
{{- if $secret -}}
  {{- if hasKey $secret.data "license" -}}
    {{- index $secret.data "license" | b64dec -}}
  {{- else -}}
    {{- fail (printf "Secret '%s' in namespace '%s' exists but does not contain a 'license' key" $secretName $namespace) -}}
  {{- end -}}
{{- else -}}
  {{/* lookup returned empty — likely helm template/dry-run; use placeholder; post-install hook will patch */}}
  {{- printf "PLACEHOLDER_LICENSE" -}}
{{- end -}}
{{- end -}}

