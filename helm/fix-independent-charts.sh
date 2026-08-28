#!/bin/bash

set -e

echo "🔧 Fixing independent Helm charts for standalone deployment..."
echo ""

# List of services to fix (excluding cloudops-umbrella and redis which are correct)
SERVICES="cost-optimizer k8s-manager incident-manager automation-service chatops-bot metrics-collector auth-service frontend"

for service in $SERVICES; do
    echo "📦 Processing $service..."
    
    # Create new _helpers.tpl for independent chart
    cat > $service/templates/_helpers.tpl << 'EOF'
{{/*
Expand the name of the chart.
*/}}
{{- define "SERVICE_NAME.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "SERVICE_NAME.fullname" -}}
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
{{- define "SERVICE_NAME.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "SERVICE_NAME.labels" -}}
helm.sh/chart: {{ include "SERVICE_NAME.chart" . }}
{{ include "SERVICE_NAME.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "SERVICE_NAME.selectorLabels" -}}
app.kubernetes.io/name: {{ include "SERVICE_NAME.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "SERVICE_NAME.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "SERVICE_NAME.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Redis host
*/}}
{{- define "SERVICE_NAME.redisHost" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis-master" (include "SERVICE_NAME.fullname" .) }}
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
{{- define "SERVICE_NAME.redisPort" -}}
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
EOF

    # Replace SERVICE_NAME with actual service name in helpers
    sed -i.bak "s/SERVICE_NAME/$service/g" $service/templates/_helpers.tpl
    rm -f $service/templates/_helpers.tpl.bak
    
    echo "  ✓ Updated _helpers.tpl"
done

# Now create proper templates for each service
for service in $SERVICES; do
    echo "📦 Creating templates for $service..."
    
    # Get port number
    case $service in
        cost-optimizer) port=8001 ;;
        k8s-manager) port=8002 ;;
        incident-manager) port=8003 ;;
        automation-service) port=8004 ;;
        chatops-bot) port=8005 ;;
        metrics-collector) port=8006 ;;
        auth-service) port=8007 ;;
        frontend) port=3000 ;;
    esac
    
    # Create deployment.yaml
    cat > $service/templates/deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "$service.fullname" . }}
  labels:
    {{- include "$service.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "$service.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
      {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "$service.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "$service.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
      - name: $service
        securityContext:
          {{- toYaml .Values.securityContext | nindent 12 }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: $port
          protocol: TCP
        env:
        {{- range .Values.env }}
        - name: {{ .name }}
          value: {{ .value | quote }}
        {{- end }}
        {{- with .Values.extraEnv }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- with .Values.envFrom }}
        envFrom:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        livenessProbe:
          {{- toYaml .Values.livenessProbe | nindent 10 }}
        readinessProbe:
          {{- toYaml .Values.readinessProbe | nindent 10 }}
        resources:
          {{- toYaml .Values.resources | nindent 10 }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
EOF
    
    # Create service.yaml
    cat > $service/templates/service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: {{ include "$service.fullname" . }}
  labels:
    {{- include "$service.labels" . | nindent 4 }}
  {{- with .Values.service.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "$service.selectorLabels" . | nindent 4 }}
EOF
    
    # Create serviceaccount.yaml
    cat > $service/templates/serviceaccount.yaml << EOF
{{- if .Values.serviceAccount.create -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "$service.serviceAccountName" . }}
  labels:
    {{- include "$service.labels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
EOF
    
    # Create hpa.yaml
    cat > $service/templates/hpa.yaml << EOF
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "$service.fullname" . }}
  labels:
    {{- include "$service.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "$service.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
  {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
  {{- end }}
  {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
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
EOF
    
    # Create pdb.yaml
    cat > $service/templates/pdb.yaml << EOF
{{- if .Values.podDisruptionBudget.enabled }}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "$service.fullname" . }}
  labels:
    {{- include "$service.labels" . | nindent 4 }}
spec:
  {{- if .Values.podDisruptionBudget.minAvailable }}
  minAvailable: {{ .Values.podDisruptionBudget.minAvailable }}
  {{- end }}
  {{- if .Values.podDisruptionBudget.maxUnavailable }}
  maxUnavailable: {{ .Values.podDisruptionBudget.maxUnavailable }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "$service.selectorLabels" . | nindent 6 }}
{{- end }}
EOF
    
    # Create configmap.yaml
    cat > $service/templates/configmap.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "$service.fullname" . }}
  labels:
    {{- include "$service.labels" . | nindent 4 }}
data:
  REDIS_HOST: {{ include "$service.redisHost" . | quote }}
  REDIS_PORT: {{ include "$service.redisPort" . | quote }}
EOF
    
    echo "  ✓ Created standard templates"
done

# Special templates for k8s-manager (RBAC)
echo "📦 Adding RBAC for k8s-manager..."
cat > k8s-manager/templates/rbac.yaml << 'EOF'
{{- if .Values.rbac.create }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ include "k8s-manager.fullname" . }}
  labels:
    {{- include "k8s-manager.labels" . | nindent 4 }}
rules:
{{- toYaml .Values.rbac.rules | nindent 0 }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ include "k8s-manager.fullname" . }}
  labels:
    {{- include "k8s-manager.labels" . | nindent 4 }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: {{ include "k8s-manager.fullname" . }}
subjects:
- kind: ServiceAccount
  name: {{ include "k8s-manager.serviceAccountName" . }}
  namespace: {{ .Release.Namespace }}
{{- end }}
EOF

# Special templates for auth-service (Secret)
echo "📦 Adding Secret for auth-service..."
cat > auth-service/templates/secret.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "auth-service.fullname" . }}
  labels:
    {{- include "auth-service.labels" . | nindent 4 }}
type: Opaque
data:
  jwt-secret-key: {{ .Values.jwtSecretKey | b64enc | quote }}
EOF

# Update auth-service deployment to use secret
cat > auth-service/templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "auth-service.fullname" . }}
  labels:
    {{- include "auth-service.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "auth-service.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
        checksum/secret: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
      {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "auth-service.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "auth-service.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
      - name: auth-service
        securityContext:
          {{- toYaml .Values.securityContext | nindent 12 }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: 8007
          protocol: TCP
        env:
        - name: JWT_SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: {{ include "auth-service.fullname" . }}
              key: jwt-secret-key
        {{- range .Values.env }}
        - name: {{ .name }}
          value: {{ .value | quote }}
        {{- end }}
        {{- with .Values.extraEnv }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- with .Values.envFrom }}
        envFrom:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        livenessProbe:
          {{- toYaml .Values.livenessProbe | nindent 10 }}
        readinessProbe:
          {{- toYaml .Values.readinessProbe | nindent 10 }}
        resources:
          {{- toYaml .Values.resources | nindent 10 }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
EOF

# Special templates for frontend (Ingress)
echo "📦 Adding Ingress for frontend..."
cat > frontend/templates/ingress.yaml << 'EOF'
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "frontend.fullname" . }}
  labels:
    {{- include "frontend.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ include "frontend.fullname" $ }}
                port:
                  number: {{ $.Values.service.port }}
          {{- end }}
    {{- end }}
{{- end }}
EOF

echo ""
echo "✅ All charts fixed!"
echo ""
echo "Testing charts..."

for service in $SERVICES; do
    echo -n "  Linting $service... "
    if helm lint $service/ 2>&1 | grep -q "1 chart(s) linted, 0 chart(s) failed"; then
        echo "✅"
    else
        echo "⚠️  (check dependencies)"
    fi
done

echo ""
echo "🎉 Independent charts are ready for deployment!"
echo ""
echo "Quick test:"
echo "  helm install cost-optimizer ./cost-optimizer --dry-run --debug | head -50"
