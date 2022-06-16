{{/*
Expand the name of the chart.
*/}}
{{- define "sandpiper.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 59 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sandpiper.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 59 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 59 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- /*
Create a fully qualified web app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "sandpiper.fullnameWeb" -}}
    {{- $name := include "sandpiper.fullname" . -}}
    {{- printf "%s-web" $name | trunc 63 }}
{{- end }}

{{- /*
Create a fully qualified api app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "sandpiper.fullnameApi" -}}
    {{- $name := include "sandpiper.fullname" . -}}
    {{- printf "%s-api" $name | trunc 63 }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sandpiper.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sandpiper.labels" -}}
helm.sh/chart: {{ include "sandpiper.chart" . }}
{{ include "sandpiper.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sandpiper.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sandpiper.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sandpiper.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sandpiper.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
