{{/*
Expand the name of the chart.
*/}}
{{- define "vdp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vdp.fullname" -}}
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
{{- define "vdp.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vdp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "vdp.labels" -}}
app.kubernetes.io/name: {{ include "vdp.name" . }}
helm.sh/chart: {{ include "vdp.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | replace "+" "_" }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end -}}

{{/*
MatchLabels
*/}}
{{- define "vdp.matchLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/name: {{ include "vdp.name" . }}
{{- end -}}

{{- define "vdp.autoGenCert" -}}
  {{- if and .Values.expose.tls.enabled (eq .Values.expose.tls.certSource "auto") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "vdp.autoGenCertForIngress" -}}
  {{- if and (eq (include "vdp.autoGenCert" .) "true") (eq .Values.expose.type "ingress") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "base.database.host" -}}
    {{- template "base.database" . -}}
{{- end -}}

{{- define "base.database.port" -}}
    {{- print "5432" -}}
{{- end -}}

{{- define "base.database.username" -}}
    {{- print "postgres" -}}
{{- end -}}

{{- define "base.database.rawPassword" -}}
    {{- print "password" -}}
{{- end -}}

/*host:port*/
{{- define "base.redis.addr" -}}
  {{- with .Values.redis -}}
    {{- default (printf "%s:6379" (include "base.redis" $ )) .addr -}}
  {{- end -}}
{{- end -}}

{{- define "base.mgmtBackend" -}}
  {{- print "base-mgmt-backend" -}}
{{- end -}}

{{- define "vdp.apiGatewayVDP" -}}
  {{- printf "%s-api-gateway-vdp" (include "vdp.fullname" .) -}}
{{- end -}}

{{- define "vdp.pipelineBackend" -}}
  {{- printf "%s-pipeline-backend" (include "vdp.fullname" .) -}}
{{- end -}}

{{- define "vdp.connectorBackend" -}}
  {{- printf "%s-connector-backend" (include "vdp.fullname" .) -}}
{{- end -}}

{{- define "vdp.controllerVDP" -}}
  {{- printf "%s-controller-vdp" (include "vdp.fullname" .) -}}
{{- end -}}

{{- define "base.database" -}}
  {{- printf "base-database" -}}
{{- end -}}

{{- define "base.redis" -}}
  {{- print "base-redis" -}}
{{- end -}}

{{- define "base.temporal" -}}
  {{- print "base-temporal" -}}
{{- end -}}

{{- define "base.etcd" -}}
  {{- print "base-etcd" -}}
{{- end -}}

{{/* api-gateway service and container port */}}
{{- define "vdp.apiGatewayVDP.httpPort" -}}
  {{- printf "8080" -}}
{{- end -}}

{{/* api-gateway service and container stats port */}}
{{- define "vdp.apiGatewayVDP.statsPort" -}}
  {{- printf "8070" -}}
{{- end -}}

{{/* api-gateway service and container metrics port */}}
{{- define "vdp.apiGatewayVDP.metricsPort" -}}
  {{- printf "8071" -}}
{{- end -}}

{{/* pipeline service and container public port */}}
{{- define "vdp.pipelineBackend.publicPort" -}}
  {{- printf "8081" -}}
{{- end -}}

{{/* pipeline service and container private port */}}
{{- define "vdp.pipelineBackend.privatePort" -}}
  {{- printf "3081" -}}
{{- end -}}

{{/* connector service and container public port */}}
{{- define "vdp.connectorBackend.publicPort" -}}
  {{- printf "8082" -}}
{{- end -}}

{{/* connector service and container private port */}}
{{- define "vdp.connectorBackend.privatePort" -}}
  {{- printf "3082" -}}
{{- end -}}

{{/* controller service and container private port */}}
{{- define "vdp.controllerVDP.privatePort" -}}
  {{- printf "3085" -}}
{{- end -}}

{{/* mgmt-backend service and container public port */}}
{{- define "base.mgmtBackend.publicPort" -}}
  {{- printf "8084" -}}
{{- end -}}

{{/* mgmt-backend service and container private port */}}
{{- define "base.mgmtBackend.privatePort" -}}
  {{- printf "3084" -}}
{{- end -}}

{{/* temporal container frontend gRPC port */}}
{{- define "base.temporal.frontend.grpcPort" -}}
  {{- printf "7233" -}}
{{- end -}}

{{/* etcd port */}}
{{- define "base.etcd.clientPort" -}}
  {{- printf "2379" -}}
{{- end -}}

{{- define "base.influxdb" -}}
  {{- printf "base-influxdb2" -}}
{{- end -}}

{{- define "base.influxdb.port" -}}
  {{- printf "8086" -}}
{{- end -}}

{{- define "base.jaeger" -}}
  {{- printf "base-jaeger-collector" -}}
{{- end -}}

{{- define "base.jaeger.port" -}}
  {{- printf "14268" -}}
{{- end -}}

{{- define "base.otel" -}}
  {{- printf "base-opentelemetry-collector" -}}
{{- end -}}

{{- define "base.otel.port" -}}
  {{- printf "8095" -}}
{{- end -}}

{{- define "vdp.internalTLS.apiGatewayVDP.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.apiGatewayVDP.secretName -}}
  {{- else -}}
    {{- printf "%s-api-gateway-vdp-internal-tls" (include "vdp.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{- define "vdp.internalTLS.pipelineBackend.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.pipelineBackend.secretName -}}
  {{- else -}}
    {{- printf "%s-pipeline-backend-internal-tls" (include "vdp.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{- define "vdp.internalTLS.connectorBackend.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.connectorBackend.secretName -}}
  {{- else -}}
    {{- printf "%s-connector-backend-internal-tls" (include "vdp.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{- define "vdp.internalTLS.controllerVDP.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.controllerVDP.secretName -}}
  {{- else -}}
    {{- printf "%s-controller-vdp-internal-tls" (include "vdp.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{/* Allow KubeVersion to be overridden. */}}
{{- define "vdp.ingress.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.expose.ingress.kubeVersionOverride -}}
{{- end -}}
