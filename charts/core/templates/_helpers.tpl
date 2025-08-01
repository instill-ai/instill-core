{{/*
Expand the name of the chart.
*/}}
{{- define "core.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "core.fullname" -}}
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
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "core.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "core.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "core.labels" -}}
app.kubernetes.io/name: {{ include "core.name" . }}
helm.sh/chart: {{ include "core.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | replace "+" "_" }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end -}}

{{/*
MatchLabels
*/}}
{{- define "core.matchLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/name: {{ include "core.name" . }}
{{- end -}}

{{/*
api-gateway
*/}}
{{- define "core.apiGateway" -}}
  {{- printf "%s-api-gateway" (include "core.fullname" .) -}}
{{- end -}}

{{/* api-gateway service and container port */}}
{{- define "core.apiGateway.httpPort" -}}
  {{- printf "8080" -}}
{{- end -}}

{{/* api-gateway service and container stats port */}}
{{- define "core.apiGateway.statsPort" -}}
  {{- printf "8070" -}}
{{- end -}}

{{/* api-gateway service and container metrics port */}}
{{- define "core.apiGateway.metricsPort" -}}
  {{- printf "8071" -}}
{{- end -}}

{{/*
mgmt-backend
*/}}
{{- define "core.mgmtBackend" -}}
  {{- printf "%s-mgmt-backend" (include "core.fullname" .) -}}
{{- end -}}

{{/* mgmt-backend service and container public port */}}
{{- define "core.mgmtBackend.publicPort" -}}
  {{- printf "8084" -}}
{{- end -}}

{{/* mgmt-backend service and container private port */}}
{{- define "core.mgmtBackend.privatePort" -}}
  {{- printf "3084" -}}
{{- end -}}

{{/*
pipeline-backend
*/}}
{{- define "core.pipelineBackend" -}}
  {{- printf "%s-pipeline-backend" (include "core.fullname" .) -}}
{{- end -}}

{{/*
pipeline-backend-worker
*/}}
{{- define "core.pipelineBackendWorker" -}}
  {{- printf "%s-pipeline-backend-worker" (include "core.fullname" .) -}}
{{- end -}}

{{/* pipeline service and container public port */}}
{{- define "core.pipelineBackend.publicPort" -}}
  {{- printf "8081" -}}
{{- end -}}

{{/* pipeline service and container private port */}}
{{- define "core.pipelineBackend.privatePort" -}}
  {{- printf "3081" -}}
{{- end -}}

{{/*
model-backend
*/}}
{{- define "core.modelBackend" -}}
  {{- printf "%s-model-backend" (include "core.fullname" .) -}}
{{- end -}}

{{/* model-backend service and container public port */}}
{{- define "core.modelBackend.publicPort" -}}
  {{- printf "8083" -}}
{{- end -}}

{{/* model-backend service and container private port */}}
{{- define "core.modelBackend.privatePort" -}}
  {{- printf "3083" -}}
{{- end -}}

{{/*
artifact-backend
*/}}
{{- define "core.artifactBackend" -}}
{{- printf "%s-artifact-backend" (include "core.fullname" .) -}}
{{- end -}}

{{/* artifact-backend service and container public port */}}
{{- define "core.artifactBackend.publicPort" -}}
{{- printf "8082" -}}
{{- end -}}

{{/* artifact-backend service and container private port */}}
{{- define "core.artifactBackend.privatePort" -}}
{{- printf "3082" -}}
{{- end -}}

{{/*
console
*/}}
{{- define "core.console" -}}
  {{- printf "%s-console" (include "core.fullname" .) -}}
{{- end -}}

{{/* console service and container port */}}
{{- define "core.console.port" -}}
  {{- printf "3000" -}}
{{- end -}}

{{/*
Temporal
*/}}
{{- define "core.temporal" -}}
  {{- printf "%s-temporal" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.temporal.admintools" -}}
  {{- printf "%s-temporal-admintools" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.temporal.ui" -}}
  {{- printf "%s-temporal-ui" (include "core.fullname" .) -}}
{{- end -}}

{{/* Temporal container frontend gRPC port */}}
{{- define "core.temporal.frontend.grpcPort" -}}
  {{- printf "7233" -}}
{{- end -}}

{{/* Temporal container frontend membership port */}}
{{- define "core.temporal.frontend.membershipPort" -}}
  {{- printf "6933" -}}
{{- end -}}

{{/* Temporal container history gRPC port */}}
{{- define "core.temporal.history.grpcPort" -}}
  {{- printf "7234" -}}
{{- end -}}

{{/* Temporal container history membership port */}}
{{- define "core.temporal.history.membershipPort" -}}
  {{- printf "6934" -}}
{{- end -}}

{{/* Temporal container matching gRPC port */}}
{{- define "core.temporal.matching.grpcPort" -}}
  {{- printf "7235" -}}
{{- end -}}

{{/* Temporal container matching membership port */}}
{{- define "core.temporal.matching.membershipPort" -}}
  {{- printf "6935" -}}
{{- end -}}

{{/* Temporal container worker gRPC port */}}
{{- define "core.temporal.worker.grpcPort" -}}
  {{- printf "7239" -}}
{{- end -}}

{{/* Temporal container worker membership port */}}
{{- define "core.temporal.worker.membershipPort" -}}
  {{- printf "6939" -}}
{{- end -}}

{{/* Temporal web container port */}}
{{- define "core.temporal.ui.port" -}}
  {{- printf "8088" -}}
{{- end -}}

{{/* temporal metrics core at the service using the SDK */}}
{{- define "core.temporal.metrics.port" -}}
  {{- printf "8096" -}}
{{- end -}}

{{/*
KubeRay
*/}}
{{- define "core.kuberay" -}}
    {{- printf "%s-kuberay" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.kuberay.host" -}}
  {{- if (index .Values "ray-cluster").enabled -}}
    {{- printf "%s-head-svc" (include "core.kuberay" .) -}}
  {{- else -}}
    {{- with index .Values "ray-cluster" }}
      {{- printf "%s" .external.host -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "core.kuberay.grpcPort" -}}
  {{- if (index .Values "ray-cluster").enabled -}}
    {{- printf "9000" -}}
  {{- else -}}
    {{- with index .Values "ray-cluster" }}
      {{- printf "%d" (int .external.port.grpc) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "core.kuberay.servePort" -}}
  {{- if (index .Values "ray-cluster").enabled -}}
    {{- printf "8000" -}}
  {{- else -}}
    {{- with index .Values "ray-cluster" }}
      {{- printf "%d" (int .external.port.serve) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "core.kuberay.dashboardPort" -}}
  {{- if (index .Values "ray-cluster").enabled -}}
    {{- printf "8265" -}}
  {{- else -}}
    {{- with index .Values "ray-cluster" }}
      {{- printf "%d" (int .external.port.dashboard) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "core.kuberay.clientPort" -}}
  {{- if (index .Values "ray-cluster").enabled -}}
    {{- printf "10001" -}}
  {{- else -}}
    {{- with index .Values "ray-cluster" }}
      {{- printf "%d" (int .external.port.client) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "core.kuberay.gcsPort" -}}
  {{- if (index .Values "ray-cluster").enabled -}}
    {{- printf "6379" -}}
  {{- else -}}
    {{- with index .Values "ray-cluster" }}
      {{- printf "%d" (int .external.port.gcs) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "core.kuberay.metricsPort" -}}
  {{- if (index .Values "ray-cluster").enabled -}}
    {{- printf "8080" -}}
  {{- else -}}
    {{- with index .Values "ray-cluster" }}
      {{- printf "%d" (int .external.port.metrics) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Database
*/}}
{{- define "core.database" -}}
  {{- printf "%s-database" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.database.host" -}}
  {{- if .Values.database.enabled -}}
    {{- template "core.database" . -}}
  {{- else -}}
    {{- .Values.database.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "core.database.port" -}}
  {{- if .Values.database.enabled -}}
    {{- printf "%s" "5432" -}}
  {{- else -}}
    {{- .Values.database.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "core.database.username" -}}
  {{- if .Values.database.enabled -}}
    {{- printf "%s" "postgres" -}}
  {{- else -}}
    {{- .Values.database.external.username -}}
  {{- end -}}
{{- end -}}

{{- define "core.database.password" -}}
  {{- if .Values.database.enabled -}}
    {{- .Values.database.password -}}
  {{- else -}}
    {{- .Values.database.external.password -}}
  {{- end -}}
{{- end -}}

{{/*
Redis
*/}}
{{- define "core.redis" -}}
  {{- printf "%s-redis" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.redis.addr" -}}
  {{- if .Values.redis.enabled -}}
    {{- printf "%s:6379" (include "core.redis" .) -}}
  {{- else -}}
    {{- .Values.redis.external.addr -}}
  {{- end -}}
{{- end -}}

{{/*
Influxdb2
*/}}
{{- define "core.influxdb2" -}}
  {{- printf "%s-influxdb2" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.influxdb2.url" -}}
  {{- if .Values.influxdb2.enabled -}}
    {{- printf "http://%s:80" (include "core.influxdb2" .) -}}
  {{- else -}}
    {{- .Values.influxdb2.external.url -}}
  {{- end -}}
{{- end -}}

{{- define "core.influxdb2.token" -}}
  {{- if .Values.influxdb2.enabled -}}
    {{- .Values.influxdb2.adminUser.token -}}
  {{- else -}}
    {{- .Values.influxdb2.external.token -}}
  {{- end -}}
{{- end -}}

{{- define "core.influxdb2.organization" -}}
  {{- if .Values.influxdb2.enabled -}}
    {{- .Values.influxdb2.adminUser.organization -}}
  {{- else -}}
    {{- .Values.influxdb2.external.organization -}}
  {{- end -}}
{{- end -}}

{{- define "core.influxdb2.bucket" -}}
  {{- if .Values.influxdb2.enabled -}}
    {{- .Values.influxdb2.adminUser.bucket -}}
  {{- else -}}
    {{- .Values.influxdb2.external.bucket -}}
  {{- end -}}
{{- end -}}

{{/*
OpenTelemetry
*/}}
{{- define "core.otel" -}}
  {{- printf "%s-opentelemetry-collector" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.otel.port" -}}
  {{- printf "4317" -}}
{{- end -}}

{{/*
OpenFGA
*/}}
{{- define "core.openfga" -}}
  {{- printf "%s-openfga" (include "core.fullname" .) -}}
{{- end -}}

{{/*
registry
*/}}
{{- define "core.registry" -}}
  {{- printf "%s-registry" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.registry.port" -}}
  {{- printf "5000" -}}
{{- end -}}

{{- define "core.registry.metricsPort" -}}
  {{- printf "5001" -}}
{{- end -}}

{{/*
Grafana
*/}}
{{- define "core.grafana" -}}
  {{- printf "%s-grafana" (include "core.fullname" .) -}}
{{- end -}}

{{/*
internal TLS secret names
*/}}
{{- define "core.internalTLS.apiGateway.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.apiGateway.secretName -}}
  {{- else -}}
    {{- printf "%s-api-gateway-internal-tls" (include "core.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{- define "core.internalTLS.mgmtBackend.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.mgmtBackend.secretName -}}
  {{- else -}}
    {{- printf "%s-mgmt-internal-tls" (include "core.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{- define "core.internalTLS.pipelineBackend.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.pipelineBackend.secretName -}}
  {{- else -}}
    {{- printf "%s-pipeline-backend-internal-tls" (include "core.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{- define "core.internalTLS.modelBackend.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.modelBackend.secretName -}}
  {{- else -}}
    {{- printf "%s-model-backend-internal-tls" (include "core.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{- define "core.internalTLS.artifactBackend.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.artifactBackend.secretName -}}
  {{- else -}}
    {{- printf "%s-artifact-backend-internal-tls" (include "core.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{- define "core.internalTLS.console.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.console.secretName -}}
  {{- else -}}
    {{- printf "%s-console-internal-tls" (include "core.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{/*
Persistent Volume Claims
*/}}
{{- define "core.registryDataVolume" -}}
  {{- printf "%s-registry-data-volume" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.databaseDataVolume" -}}
  {{- printf "%s-database-data-volume" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.redisDataVolume" -}}
  {{- printf "%s-redis-data-volume" (include "core.fullname" .) -}}
{{- end -}}

{{/*
Allow KubeVersion to be overridden.
*/}}
{{- define "core.ingress.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.expose.ingress.kubeVersionOverride -}}
{{- end -}}

{{/*
MinIO
*/}}
{{- define "minio.host" -}}
  {{- printf "minio-tenant-hl.minio.svc.cluster.local" -}}
{{- end -}}

{{- define "minio.port" -}}
  {{- printf "9000" -}}
{{- end -}}

{{/*
Milvus
*/}}
{{- define "milvus.host" -}}
  {{- printf "milvus-milvus.milvus.svc.cluster.local" -}}
{{- end -}}

{{- define "milvus.port" -}}
  {{- printf "19530" -}}
{{- end -}}

{{- define "milvus.metricsPort" -}}
  {{- printf "9091" -}}
{{- end -}}
