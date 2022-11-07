{{/*
Create inference server name.
*/}}
{{- define "triton-backend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "triton-backend.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
  Create inference server metrics monitor name and fullname derived from
  above and truncated appropriately.
*/}}
{{- define "triton-backend-metrics-monitor.name" -}}
{{- $basename := include "triton-backend.name" . -}}
{{- $basename_trimmed := $basename | trunc 47 | trimSuffix "-" -}}
{{- printf "%s-%s" $basename_trimmed "metrics-monitor" -}}
{{- end -}}

{{- define "triton-backend-metrics-monitor.fullname" -}}
{{- $basename := include "triton-backend.fullname" . -}}
{{- $basename_trimmed := $basename | trunc 47 | trimSuffix "-" -}}
{{- printf "%s-%s" $basename_trimmed "metrics-monitor" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "triton-backend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "triton-backend.labels" -}}
helm.sh/chart: {{ include "triton-backend.chart" . }}
{{ include "triton-backend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "triton-backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "triton-backend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Triton server image tag
*/}}
{{- define "triton-backend.dockerImageTag" -}}
{{- if eq .Values.arch "arm64" -}}
{{- printf "%v-py3-cpu-arm64" .Values.image.tag -}}
{{- else -}}
{{- printf "%v-py3" .Values.image.tag -}}
{{- end }}
{{- end }}

{{/*
Triton conda environment image tag
*/}}
{{- define "triton-backend.tritonEnvImageTag" -}}
{{- if eq .Values.arch "arm64" -}}
{{- printf "%v-m1" .Values.tritonEnv.tag -}}
{{- else -}}
{{- printf "%v-cpu" .Values.tritonEnv.tag -}}
{{- end }}
{{- end }}