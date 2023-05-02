{{/*
Expand the name of the chart.
*/}}
{{- define "porter-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "porter-agent.fullname" -}}
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
{{- define "porter-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create porter agent image tag.
*/}}
{{- define "porter-agent.imageTag" -}}
{{ .Chart.AppVersion }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "porter-agent.labels" -}}
helm.sh/chart: {{ include "porter-agent.chart" . }}
{{ include "porter-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Agent labels
*/}}
{{- define "porter-agent.agentLabels" -}}
helm.sh/chart: {{ include "porter-agent.chart" . }}
{{ include "porter-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
porter: "true"
{{- end }}

{{/*
Selector labels
*/}}
{{- define "porter-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "porter-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the porter installation service account to use
*/}}
{{- define "porter-agent.installationServiceAccountName" -}}
{{- if .Values.porterAgent.serviceAccount.installation.create }}
{{- default "installation-service-account" .Values.porterAgent.serviceAccount.installation.name }}
{{- else }}
{{- default "installation-service-account" .Values.porterAgent.serviceAccount.installation.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the porter agent service account to use
*/}}
{{- define "porter-agent.agentServiceAccountName" -}}
{{- if .Values.porterAgent.serviceAccount.agent.create }}
{{- default (include "porter-agent.name" .) .Values.porterAgent.serviceAccount.agent.name }}
{{- else }}
{{- default "porter-agent" .Values.porterAgent.serviceAccount.agent.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the porter env secret
*/}}
{{- define "porter-agent.envSecretName" -}}
{{- if .Values.porterAgent.secret.env.create }}
{{- default "porter-env" .Values.porterAgent.serviceAccount.agent.name }}
{{- else }}
{{- default "porter-env" .Values.porterAgent.serviceAccount.agent.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the porter agent config secret
*/}}
{{- define "porter-agent.configSecretName" -}}
{{- default "porter-config" .Values.porterAgent.serviceAccount.agent.name }}
{{- end }}