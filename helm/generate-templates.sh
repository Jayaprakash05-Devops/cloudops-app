#!/bin/bash

# Script to generate Helm templates for all services
# Each service gets: deployment, service, hpa, pdb, configmap

SERVICES=(
  "k8s-manager:8002:k8sManager"
  "incident-manager:8003:incidentManager"
  "automation-service:8004:automationService"
  "chatops-bot:8005:chatopsBot"
  "metrics-collector:8006:metricsCollector"
  "frontend:3000:frontend"
)

for service_info in "${SERVICES[@]}"; do
  IFS=':' read -r service port values_key <<< "$service_info"
  
  mkdir -p helm/cloudops/templates/$service
  
  # Generate Deployment
  cat > helm/cloudops/templates/$service/deployment.yaml << DEPLOYEOF
{{- if .Values.$values_key.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "cloudops.fullname" . }}-$service
  labels:
    {{- include "cloudops.labels" . | nindent 4 }}
    {{- include "cloudops.serviceLabels" (dict "component" "$service") | nindent 4 }}
spec:
  {{- if not .Values.$values_key.autoscaling.enabled }}
  replicas: {{ .Values.$values_key.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "cloudops.selectorLabels" . | nindent 6 }}
      app.kubernetes.io/component: $service
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print \$.Template.BasePath "/$service/configmap.yaml") . | sha256sum }}
      labels:
        {{- include "cloudops.selectorLabels" . | nindent 8 }}
        app.kubernetes.io/component: $service
    spec:
      {{- with .Values.global.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      securityContext:
        {{- toYaml .Values.common.securityContext | nindent 8 }}
      containers:
      - name: $service
        image: {{ include "cloudops.image" (dict "global" .Values.global "image" .Values.$values_key.image "defaultTag" .Chart.AppVersion) }}
        imagePullPolicy: {{ .Values.common.image.pullPolicy }}
        ports:
        - name: http
          containerPort: {{ .Values.$values_key.service.targetPort }}
          protocol: TCP
        env:
        {{- range .Values.$values_key.env }}
        - name: {{ .name }}
          value: {{ tpl .value \$ | quote }}
        {{- end }}
        {{- with .Values.$values_key.envFrom }}
        envFrom:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        livenessProbe:
          {{- toYaml .Values.common.livenessProbe | nindent 10 }}
        readinessProbe:
          {{- toYaml .Values.common.readinessProbe | nindent 10 }}
        resources:
          {{- toYaml .Values.$values_key.resources | nindent 10 }}
        volumeMounts:
        - name: tmp
          mountPath: /tmp
        - name: cache
          mountPath: /.cache
      volumes:
      - name: tmp
        emptyDir: {}
      - name: cache
        emptyDir: {}
      {{- with .Values.$values_key.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.$values_key.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.$values_key.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
DEPLOYEOF

  # Generate Service
  cat > helm/cloudops/templates/$service/service.yaml << SVCEOF
{{- if .Values.$values_key.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "cloudops.fullname" . }}-$service
  labels:
    {{- include "cloudops.labels" . | nindent 4 }}
    {{- include "cloudops.serviceLabels" (dict "component" "$service") | nindent 4 }}
  {{- with .Values.common.service.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  type: {{ .Values.common.service.type }}
  ports:
  - port: {{ .Values.$values_key.service.port }}
    targetPort: http
    protocol: TCP
    name: http
  selector:
    {{- include "cloudops.selectorLabels" . | nindent 4 }}
    app.kubernetes.io/component: $service
{{- end }}
SVCEOF

  # Generate HPA
  cat > helm/cloudops/templates/$service/hpa.yaml << HPAEOF
{{- if and .Values.$values_key.enabled .Values.$values_key.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "cloudops.fullname" . }}-$service
  labels:
    {{- include "cloudops.labels" . | nindent 4 }}
    {{- include "cloudops.serviceLabels" (dict "component" "$service") | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "cloudops.fullname" . }}-$service
  minReplicas: {{ .Values.$values_key.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.$values_key.autoscaling.maxReplicas }}
  metrics:
  {{- if .Values.$values_key.autoscaling.targetCPUUtilizationPercentage }}
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {{ .Values.$values_key.autoscaling.targetCPUUtilizationPercentage }}
  {{- end }}
  {{- if .Values.$values_key.autoscaling.targetMemoryUtilizationPercentage }}
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: {{ .Values.$values_key.autoscaling.targetMemoryUtilizationPercentage }}
  {{- end }}
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
      - type: Pods
        value: 2
        periodSeconds: 60
      selectPolicy: Min
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 30
      - type: Pods
        value: 4
        periodSeconds: 30
      selectPolicy: Max
{{- end }}
HPAEOF

  # Generate PDB
  cat > helm/cloudops/templates/$service/pdb.yaml << PDBEOF
{{- if and .Values.$values_key.enabled .Values.$values_key.podDisruptionBudget.enabled }}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "cloudops.fullname" . }}-$service
  labels:
    {{- include "cloudops.labels" . | nindent 4 }}
    {{- include "cloudops.serviceLabels" (dict "component" "$service") | nindent 4 }}
spec:
  {{- if .Values.$values_key.podDisruptionBudget.minAvailable }}
  minAvailable: {{ .Values.$values_key.podDisruptionBudget.minAvailable }}
  {{- end }}
  {{- if .Values.$values_key.podDisruptionBudget.maxUnavailable }}
  maxUnavailable: {{ .Values.$values_key.podDisruptionBudget.maxUnavailable }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "cloudops.selectorLabels" . | nindent 6 }}
      app.kubernetes.io/component: $service
{{- end }}
PDBEOF

  # Generate ConfigMap
  cat > helm/cloudops/templates/$service/configmap.yaml << CMEOF
{{- if .Values.$values_key.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "cloudops.fullname" . }}-$service
  labels:
    {{- include "cloudops.labels" . | nindent 4 }}
    {{- include "cloudops.serviceLabels" (dict "component" "$service") | nindent 4 }}
data:
  REDIS_HOST: {{ include "cloudops.redisHost" . | quote }}
  REDIS_PORT: {{ include "cloudops.redisPort" . | quote }}
{{- end }}
CMEOF

  echo "✓ Generated templates for $service"
done

echo ""
echo "✅ All service templates generated!"
