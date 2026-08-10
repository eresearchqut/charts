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
When serviceAccount.enabled is true, uses serviceAccount.name if set, otherwise
falls back to the chart fullname. When enabled is false, uses serviceAccount.name
if set, otherwise falls back to "default".
*/}}
{{- define "component-based-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.enabled }}
{{- .Values.serviceAccount.name | default (include "component-based-app.fullname" .) }}
{{- else }}
{{- .Values.serviceAccount.name | default "default" }}
{{- end }}
{{- end }}

{{/*
Public ingress rule snippet for the ingress controller (0.0.0.0/0) on the given port.
Usage: {{ include "component-based-app.ingressPublicRule" <port> | nindent 4 }}
*/}}
{{- define "component-based-app.ingressPublicRule" -}}
- from:
    - ipBlock:
        cidr: 0.0.0.0/0
  ports:
    - port: {{ . }}
      protocol: TCP
{{- end -}}

{{/*
Name of the CNPG Cluster created by the aliased "database" subchart
(cloudnative-pg "cluster" chart). Mirrors the subchart's "cluster.fullname"
helper: alias rewrites .Chart.Name to "database".
*/}}
{{- define "component-based-app.databaseClusterName" -}}
{{- if .Values.database.fullnameOverride }}
{{- .Values.database.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := .Values.database.nameOverride | default "database" }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Secret holding the application database credentials (keys: username, password).
Uses cluster.initdb.secret.name when the user supplies one, otherwise the
CNPG auto-generated "<cluster>-app" secret.
*/}}
{{- define "component-based-app.databaseSecretName" -}}
{{- $initdbSecret := dig "cluster" "initdb" "secret" "name" "" .Values.database }}
{{- $initdbSecret | default (printf "%s-app" (include "component-based-app.databaseClusterName" .)) }}
{{- end }}

{{/*
HTTP probe body with chart defaults. Key validation is enforced by
values.schema.json (additionalProperties: false per probe), so unknown keys
hard-fail at helm template time; anything the schema admits passes through.
Context: dict "kind" <"liveness"|"readiness"|"startup"> "probe" <map>
*/}}
{{- define "component-based-app.httpProbe" -}}
{{- $defaults := dict "initialDelaySeconds" 0 "periodSeconds" 10 "timeoutSeconds" 1 "failureThreshold" 3 "successThreshold" 1 }}
{{- if eq .kind "startup" }}
{{- /* Kubernetes fixes successThreshold=1 for startup probes; slow starts get a higher failureThreshold */}}
{{- $defaults = dict "initialDelaySeconds" 0 "periodSeconds" 10 "timeoutSeconds" 1 "failureThreshold" 30 }}
{{- end -}}
httpGet:
  path: {{ .probe.path }}
  port: http
{{ mergeOverwrite $defaults (omit .probe "path") | toYaml }}
{{- end }}
