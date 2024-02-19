{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "openldap.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "openldap.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "openldap.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "openldap.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (printf "%s-foo" (include "common.names.fullname" .)) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Generate chart secret name
*/}}
{{- define "openldap.secretName" -}}
{{ default (include "openldap.fullname" .) .Values.existingSecret }}
{{- end -}}

{{/*
Renders a value that contains template.
Usage:
{{ include "openldap.tplValue" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "openldap.tplValue" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Return the proper Openldap image name
*/}}
{{- define "openldap.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "openldap.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image ) "global" .Values.global) }}
{{- end -}}


{{/*
Return the proper Openldap init container image name
*/}}
{{- define "openldap.initTLSSecretImage" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.initTLSSecret.image "global" .Values.global) -}}
{{- end -}}


{{/*
Return the list of builtin schema files to mount
Cannot return list => return string comma separated
*/}}
{{- define "openldap.builtinSchemaFiles" -}}
  {{- $schemas := "" -}}
  {{- if .Values.replication -}}
    {{- $schemas = "syncprov,serverid,csyncprov,rep,bsyncprov,brep,acls" -}}
  {{- else -}}
    {{- $schemas = "acls" -}}
  {{- end -}}
  {{- print $schemas -}}
{{- end -}}

{{/*
Return the list of custom schema files to use
Cannot return list => return string comma separated
*/}}
{{- define "openldap.customSchemaFiles" -}}
  {{- $schemas := "" -}}
  {{- $schemas := ((join "," (.Values.customSchemaFiles | keys))  | replace ".ldif" "") -}}
  {{- print $schemas -}}
{{- end -}}

{{/*
Return the list of all schema files to use
Cannot return list => return string comma separated
*/}}
{{- define "openldap.schemaFiles" -}}
  {{- $schemas := (include "openldap.builtinSchemaFiles" .) -}}
  {{- $custom_schemas := (include "openldap.customSchemaFiles" .) -}}
  {{- if gt (len $custom_schemas) 0 -}}
    {{- $schemas = print $schemas "," $custom_schemas -}}
  {{- end -}}
  {{- print $schemas -}}
{{- end -}}

{{/*
Return the proper base domain
*/}}
{{- define "global.baseDomain" -}}
{{- $bd := include "tmp.baseDomain" .}}
{{- printf "%s" $bd | trimSuffix "," -}}
{{- end }}

{{/*
tmp method to iterate through the ldapDomain
*/}}
{{- define "tmp.baseDomain" -}}
{{- if regexMatch ".*=.*,.*" .Values.env.LDAP_DOMAIN }}
{{- printf "%s" .Values.env.LDAP_DOMAIN }}
{{- else }}
{{- $parts := split "." .Values.env.LDAP_DOMAIN }}
  {{- range $index, $part := $parts }}
  {{- $index1 := $index | add 1 -}}
dc={{ $part }},
  {{- end}}
  {{- end -}}
{{- end -}}
