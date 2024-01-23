{{/*
Expand the name of the chart.
*/}}
{{- define "collator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "collator.fullname" -}}
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
Create a name of api component
*/}}
{{- define "collator.fullnameApi" -}}
{{- printf "%s-%s" (include "collator.fullname" .) "api" -}}
{{- end }}

{{/*
Create a name of web component
*/}}
{{- define "collator.fullnameWeb" -}}
{{- printf "%s-%s" (include "collator.fullname" .) "web" -}}
{{- end }}

{{/*
Create a name of engine component
*/}}
{{- define "collator.fullnameEngine" -}}
{{- printf "%s-%s" (include "collator.fullname" .) "engine" -}}
{{- end }}

{{/*
Create a name of rabbit-mq component
*/}}
{{- define "collator.fullnameRabbitmq" -}}
{{- printf "%s-%s" (include "collator.fullname" .) "rabbitmq" -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "collator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "collator.labels" -}}
helm.sh/chart: {{ include "collator.chart" . }}
{{ include "collator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
API labels
*/}}
{{- define "collator.labelsApi" -}}
{{ include "collator.labels" . }}
app.kubernetes.io/component: api
{{- end }}

{{/*
Engine labels
*/}}
{{- define "collator.labelsEngine" -}}
{{ include "collator.labels" . }}
app.kubernetes.io/component: engine
{{- end }}

{{/*
Rabbit MQ labels
*/}}
{{- define "collator.labelsRabbitmq" -}}
{{ include "collator.labels" . }}
app.kubernetes.io/component: rabbitmq
{{- end }}

{{/*
Web labels
*/}}
{{- define "collator.labelsWeb" -}}
{{ include "collator.labels" . }}
app.kubernetes.io/component: web
{{- end }}

{{/*
Selector labels
*/}}
{{- define "collator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "collator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
API Selector labels
*/}}
{{- define "collator.selectorLabelsApi" -}}
{{ include "collator.selectorLabels" . }}
app.kubernetes.io/component: api
{{- end }}

{{/*
Engine Selector labels
*/}}
{{- define "collator.selectorLabelsEngine" -}}
{{ include "collator.selectorLabels" . }}
app.kubernetes.io/component: engine
{{- end }}

{{/*
Rabbit MQ Selector labels
*/}}
{{- define "collator.selectorLabelsRabbitmq" -}}
{{ include "collator.selectorLabels" . }}
app.kubernetes.io/component: rabbitmq
{{- end }}

{{/*
Web Selector labels
*/}}
{{- define "collator.selectorLabelsWeb" -}}
{{ include "collator.selectorLabels" . }}
app.kubernetes.io/component: web
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "collator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "collator.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
