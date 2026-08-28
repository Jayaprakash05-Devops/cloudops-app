{{/*
Expand the name of the chart.
*/}}
{{- define "metrics-collector.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "metrics-collector.fullname" -}}
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
{{- define "metrics-collector.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "metrics-collector.labels" -}}
helm.sh/chart: {{ include "metrics-collector.chart" . }}
{{ include "metrics-collector.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "metrics-collector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "metrics-collector.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "metrics-collector.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "metrics-collector.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Redis host
*/}}
{{- define "metrics-collector.redisHost" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis-master" (include "metrics-collector.fullname" .) }}
{{- else }}
{{- range .Values.env }}
{{- if eq .name "REDIS_HOST" }}
{{- .value }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Redis port
*/}}
{{- define "metrics-collector.redisPort" -}}
{{- if .Values.redis.enabled }}
{{- print "6379" }}
{{- else }}
{{- range .Values.env }}
{{- if eq .name "REDIS_PORT" }}
{{- .value }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
