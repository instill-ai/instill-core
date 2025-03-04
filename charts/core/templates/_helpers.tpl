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
Ray fullname
*/}}
{{- define "ray.fullname" -}}
  {{- if .Values.rayService.namespaceOverride -}}
    {{- .Values.rayService.namespaceOverride -}}
  {{- else -}}
    {{- printf "%s" (include "core.name" .) -}}
  {{- end -}}
{{- end -}}

{{/*
Inter namespace DNS suffix
*/}}
{{- define "ray.suffix" -}}
  {{- if .Values.rayService.namespaceOverride -}}
    {{- printf ".%s.svc.cluster.local" (include "ray.fullname" .) -}}
  {{- else -}}
    {{- printf "" -}}
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
Flags for auto-gen TLS certifacte
*/}}
{{- define "core.autoGenCert" -}}
  {{- if and .Values.expose.tls.enabled (eq .Values.expose.tls.certSource "auto") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "core.autoGenCertForIngress" -}}
  {{- if and (eq (include "core.autoGenCert" .) "true") (eq .Values.expose.type "ingress") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
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
temopral
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

{{/* temporal container frontend gRPC port */}}
{{- define "core.temporal.frontend.grpcPort" -}}
  {{- printf "7233" -}}
{{- end -}}

{{/* temporal container frontend membership port */}}
{{- define "core.temporal.frontend.membershipPort" -}}
  {{- printf "6933" -}}
{{- end -}}

{{/* temporal container history gRPC port */}}
{{- define "core.temporal.history.grpcPort" -}}
  {{- printf "7234" -}}
{{- end -}}

{{/* temporal container history membership port */}}
{{- define "core.temporal.history.membershipPort" -}}
  {{- printf "6934" -}}
{{- end -}}

{{/* temporal container matching gRPC port */}}
{{- define "core.temporal.matching.grpcPort" -}}
  {{- printf "7235" -}}
{{- end -}}

{{/* temporal container matching membership port */}}
{{- define "core.temporal.matching.membershipPort" -}}
  {{- printf "6935" -}}
{{- end -}}

{{/* temporal container worker gRPC port */}}
{{- define "core.temporal.worker.grpcPort" -}}
  {{- printf "7239" -}}
{{- end -}}

{{/* temporal container worker membership port */}}
{{- define "core.temporal.worker.membershipPort" -}}
  {{- printf "6939" -}}
{{- end -}}

{{/* temporal web container port */}}
{{- define "core.temporal.ui.port" -}}
  {{- printf "8088" -}}
{{- end -}}

{{- define "core.kuberay-operator" -}}
  {{- printf "%s-kuberay-operator" (include "ray.fullname" .) -}}
{{- end -}}

{{- define "core.ray-service" -}}
  {{- printf "%s-ray" (include "ray.fullname" .) -}}
{{- end -}}

{{- define "core.ray" -}}
  {{- printf "%s-ray-head-svc%s" (include "ray.fullname" .) (include "ray.suffix" .) -}}
{{- end -}}

{{- define "core.ray.clientPort" -}}
  {{- printf "10001" -}}
{{- end -}}

{{- define "core.ray.dashboardPort" -}}
  {{- printf "8265" -}}
{{- end -}}

{{- define "core.ray.gcsPort" -}}
  {{- printf "6379" -}}
{{- end -}}

{{- define "core.ray.servePort" -}}
  {{- printf "8000" -}}
{{- end -}}

{{- define "core.ray.serveGrpcPort" -}}
  {{- printf "9000" -}}
{{- end -}}

{{- define "core.ray.prometheusPort" -}}
  {{- printf "8079" -}}
{{- end -}}

{{/*
database
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

{{- define "core.database.rawPassword" -}}
  {{- if .Values.database.enabled -}}
    {{- .Values.database.password -}}
  {{- else -}}
    {{- .Values.database.external.password -}}
  {{- end -}}
{{- end -}}

{{/*
redis address host:port
*/}}
{{- define "core.redis.addr" -}}
  {{- with .Values.redis -}}
    {{- ternary (printf "%s:6379" (include "core.redis" $ )) .external.addr .enabled -}}
  {{- end -}}
{{- end -}}

{{- define "core.redis" -}}
  {{- printf "%s-redis" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.database.encryptedPassword" -}}
  {{- include "core.database.rawPassword" . | b64enc | quote -}}
{{- end -}}

{{/*
influxdb
*/}}
{{- define "core.influxdb" -}}
  {{- printf "%s-influxdb2" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.influxdb.port" -}}
  {{- printf "8086" -}}
{{- end -}}

{{/*
jaeger
*/}}
{{- define "core.jaeger" -}}
  {{- printf "%s-jaeger-collector" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.jaeger.port" -}}
  {{- printf "14268" -}}
{{- end -}}

{{/*
otel
*/}}
{{- define "core.otel" -}}
  {{- printf "%s-opentelemetry-collector" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.otel.port" -}}
  {{- printf "8095" -}}
{{- end -}}

{{/*
openfga
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
milvus
*/}}
{{- define "core.milvus" -}}
  {{- printf "%s-milvus" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.milvus.port" -}}
  {{- printf "19530" -}}
{{- end -}}

{{- define "core.milvus.metricPort" -}}
  {{- printf "9091" -}}
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
{{- define "core.modelConfigDataVolume" -}}
  {{- printf "%s-model-config-data-volume" (include "core.fullname" .) -}}
{{- end -}}

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
minio
*/}}
{{- define "core.minio" -}}
  {{- printf "%s-minio" (include "core.fullname" .) -}}
{{- end -}}

{{- define "core.minio.port" -}}
  {{- printf "9000" -}}
{{- end -}}