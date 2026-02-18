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
Resolve license value from secret (preferred) or direct value (fallback).
Priority: 1) licenseSecretName if secret exists and has 'license' key, 2) direct license value
If licenseSecretName is configured but lookup fails (e.g. helm template), skip validation
as the post-install hook will patch the real value from the mounted secret.
Usage: {{ include "kinetica-operators.resolveLicense" (dict "Values" .Values "Release" .Release) }}
*/}}
{{- define "kinetica-operators.resolveLicense" -}}
{{- $license := "" -}}
{{- $namespace := .Values.kineticacluster.namespace | default .Release.Namespace -}}
{{- $usedSecret := false -}}
{{- $hasSecretName := and .Values.kineticacluster.gpudbCluster.licenseSecretName (ne .Values.kineticacluster.gpudbCluster.licenseSecretName "") -}}
{{/* Try secret first if specified */}}
{{- if $hasSecretName -}}
  {{- $secretName := .Values.kineticacluster.gpudbCluster.licenseSecretName -}}
  {{- $secret := lookup "v1" "Secret" $namespace $secretName -}}
  {{- if $secret -}}
    {{- if hasKey $secret.data "license" -}}
      {{- $license = index $secret.data "license" | b64dec -}}
      {{- $usedSecret = true -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{/* Fall back to direct value if secret not used */}}
{{- if not $usedSecret -}}
  {{- if and .Values.kineticacluster.gpudbCluster.license (ne .Values.kineticacluster.gpudbCluster.license "") -}}
    {{- $license = .Values.kineticacluster.gpudbCluster.license -}}
  {{- else -}}
    {{- fail "A valid license is required. Provide kineticacluster.gpudbCluster.license or a valid kineticacluster.gpudbCluster.licenseSecretName (secret must have 'license' key)" -}}
  {{- end -}}
{{- end -}}
{{- $license -}}
{{- end -}}

{{/*
Resolve admin username from secret (preferred) or direct value (fallback).
Priority: 1) adminUserSecretName if secret exists and has 'username' key, 2) direct name value
Usage: {{ include "kinetica-operators.resolveAdminUsername" (dict "Values" .Values "Release" .Release) }}
*/}}
{{- define "kinetica-operators.resolveAdminUsername" -}}
{{- $username := .Values.dbAdminUser.name -}}
{{- $namespace := .Values.kineticacluster.namespace | default .Release.Namespace -}}
{{- if and .Values.dbAdminUser.adminUserSecretName (ne .Values.dbAdminUser.adminUserSecretName "") -}}
  {{- $secretName := .Values.dbAdminUser.adminUserSecretName -}}
  {{- $secret := lookup "v1" "Secret" $namespace $secretName -}}
  {{- if $secret -}}
    {{- if hasKey $secret.data "username" -}}
      {{- $username = index $secret.data "username" | b64dec -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $username -}}
{{- end -}}

{{/*
Resolve admin password from secret (preferred) or direct value (fallback).
Priority: 1) adminUserSecretName if secret exists and has 'password' key, 2) direct password value
If adminUserSecretName is configured but lookup fails (e.g. helm template), skip validation
as the post-install hook will patch the real value from the mounted secret.
Usage: {{ include "kinetica-operators.resolveAdminPassword" (dict "Values" .Values "Release" .Release) }}
*/}}
{{- define "kinetica-operators.resolveAdminPassword" -}}
{{- $password := .Values.dbAdminUser.password -}}
{{- $namespace := .Values.kineticacluster.namespace | default .Release.Namespace -}}
{{- $hasSecretName := and .Values.dbAdminUser.adminUserSecretName (ne .Values.dbAdminUser.adminUserSecretName "") -}}
{{- if $hasSecretName -}}
  {{- $secretName := .Values.dbAdminUser.adminUserSecretName -}}
  {{- $secret := lookup "v1" "Secret" $namespace $secretName -}}
  {{- if $secret -}}
    {{- if hasKey $secret.data "password" -}}
      {{- $password = index $secret.data "password" | b64dec -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- if and (eq $password "") (not $hasSecretName) -}}
  {{- fail "Password for Admin User is required. Provide dbAdminUser.password or a valid dbAdminUser.adminUserSecretName (secret must have 'password' key)" -}}
{{- end -}}
{{- $password -}}
{{- end -}}

