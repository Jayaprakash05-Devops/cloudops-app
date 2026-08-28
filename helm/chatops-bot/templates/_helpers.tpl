{{/*
Expand the name of the chart.
*/}}
{{- define "chatops-bot.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "chatops-bot.fullname" -}}
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
{{- define "chatops-bot.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "chatops-bot.labels" -}}
helm.sh/chart: {{ include "chatops-bot.chart" . }}
{{ include "chatops-bot.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "chatops-bot.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chatops-bot.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "chatops-bot.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "chatops-bot.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Redis host
*/}}
{{- define "chatops-bot.redisHost" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis-master" (include "chatops-bot.fullname" .) }}
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
{{- define "chatops-bot.redisPort" -}}
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
