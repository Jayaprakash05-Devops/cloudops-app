{{/*
Expand the name of the chart.
*/}}
{{- define "cost-optimizer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "cost-optimizer.fullname" -}}
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
{{- define "cost-optimizer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cost-optimizer.labels" -}}
helm.sh/chart: {{ include "cost-optimizer.chart" . }}
{{ include "cost-optimizer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cost-optimizer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cost-optimizer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cost-optimizer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cost-optimizer.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Redis host
*/}}
{{- define "cost-optimizer.redisHost" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis-master" (include "cost-optimizer.fullname" .) }}
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
{{- define "cost-optimizer.redisPort" -}}
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
