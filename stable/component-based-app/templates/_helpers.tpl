{{/*
Full name: release-chart, or just release when it already contains the chart name.
Truncated to 63 chars (Kubernetes label limit) and stripped of trailing hyphens.
Respects .Values.fullnameOverride when set.
*/}}
{{- define "component-based-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := include "component-based-app.name" . }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart name, truncated to 63 chars. Respects .Values.nameOverride when set.
*/}}
{{- define "component-based-app.name" -}}
{{- .Values.nameOverride | default .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "component-based-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels used by matchLabels and Service selectors.
*/}}
{{- define "component-based-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "component-based-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Standard Helm labels applied to every resource.
*/}}
{{- define "component-based-app.labels" -}}
helm.sh/chart: {{ include "component-based-app.chart" . }}
{{ include "component-based-app.selectorLabels" . }}
{{- if .Values.appVersion }}
app.kubernetes.io/version: {{ .Values.appVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Service account name used by Deployments.
When serviceAccount.create is true, uses serviceAccount.name if set, otherwise
falls back to the chart fullname. When create is false, uses serviceAccount.name
if set, otherwise falls back to "default".
*/}}
{{- define "component-based-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- .Values.serviceAccount.name | default (include "component-based-app.fullname" .) }}
{{- else }}
{{- .Values.serviceAccount.name | default "default" }}
{{- end }}
{{- end }}

{{/*
Return the autoscaling configuration for a component, defaulting to disabled.
Usage: {{ include "component-based-app.autoscaling" (dict "spec" $spec) }}
*/}}
{{- define "component-based-app.autoscaling" -}}
{{- .spec.autoscaling | toYaml -}}
{{- end -}}
