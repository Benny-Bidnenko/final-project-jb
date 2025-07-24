{{/*
Expand the name of the chart.
*/}}
{{- define "flask-aws-monitor.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "flask-aws-monitor.fullname" -}}
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
{{- define "flask-aws-monitor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "flask-aws-monitor.labels" -}}
helm.sh/chart: {{ include "flask-aws-monitor.chart" . }}
{{ include "flask-aws-monitor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: backend
app.kubernetes.io/part-of: final-project-jb
{{- end }}

{{/*
Selector labels
*/}}
{{- define "flask-aws-monitor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "flask-aws-monitor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "flask-aws-monitor.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "flask-aws-monitor.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the AWS credentials secret
*/}}
{{- define "flask-aws-monitor.secretName" -}}
{{- if .Values.deployment.awsCredentials.existingSecret }}
{{- .Values.deployment.awsCredentials.existingSecret }}
{{- else }}
{{- printf "%s-aws-credentials" (include "flask-aws-monitor.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the Docker image name
*/}}
{{- define "flask-aws-monitor.image" -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag }}
{{- end }}
