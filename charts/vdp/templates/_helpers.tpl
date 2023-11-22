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

{{- define "core.database.host" -}}
    {{- template "core.database" . -}}
{{- end -}}

{{- define "core.database.port" -}}
    {{- print "5432" -}}
{{- end -}}

{{- define "core.database.username" -}}
    {{- print "postgres" -}}
{{- end -}}

{{- define "core.database.rawPassword" -}}
    {{- print "password" -}}
{{- end -}}

/*host:port*/
{{- define "core.redis.addr" -}}
  {{- with .Values.redis -}}
    {{- default (printf "%s:6379" (include "core.redis" $ )) .addr -}}
  {{- end -}}
{{- end -}}

{{- define "core.mgmtBackend" -}}
  {{- print "core-mgmt-backend" -}}
{{- end -}}

{{- define "vdp.pipelineBackend" -}}
  {{- printf "%s-pipeline-backend" (include "vdp.fullname" .) -}}
{{- end -}}


{{- define "vdp.controllerVDP" -}}
  {{- printf "%s-controller-vdp" (include "vdp.fullname" .) -}}
{{- end -}}

{{- define "core.database" -}}
  {{- printf "core-database" -}}
{{- end -}}

{{- define "core.redis" -}}
  {{- print "core-redis" -}}
{{- end -}}

{{- define "core.temporal" -}}
  {{- print "core-temporal" -}}
{{- end -}}

{{- define "core.etcd" -}}
  {{- print "core-etcd" -}}
{{- end -}}

{{/* pipeline service and container public port */}}
{{- define "vdp.pipelineBackend.publicPort" -}}
  {{- printf "8081" -}}
{{- end -}}

{{/* pipeline service and container private port */}}
{{- define "vdp.pipelineBackend.privatePort" -}}
  {{- printf "3081" -}}
{{- end -}}

{{/* controller service and container private port */}}
{{- define "vdp.controllerVDP.privatePort" -}}
  {{- printf "3085" -}}
{{- end -}}

{{/* mgmt-backend service and container public port */}}
{{- define "core.mgmtBackend.publicPort" -}}
  {{- printf "8084" -}}
{{- end -}}

{{/* mgmt-backend service and container private port */}}
{{- define "core.mgmtBackend.privatePort" -}}
  {{- printf "3084" -}}
{{- end -}}

{{/* temporal container frontend gRPC port */}}
{{- define "core.temporal.frontend.grpcPort" -}}
  {{- printf "7233" -}}
{{- end -}}

{{/* etcd port */}}
{{- define "core.etcd.clientPort" -}}
  {{- printf "2379" -}}
{{- end -}}

{{- define "core.influxdb" -}}
  {{- printf "core-influxdb2" -}}
{{- end -}}

{{- define "core.influxdb.port" -}}
  {{- printf "8086" -}}
{{- end -}}

{{- define "core.jaeger" -}}
  {{- printf "core-jaeger-collector" -}}
{{- end -}}

{{- define "core.jaeger.port" -}}
  {{- printf "14268" -}}
{{- end -}}

{{- define "core.otel" -}}
  {{- printf "core-opentelemetry-collector" -}}
{{- end -}}

{{- define "core.otel.port" -}}
  {{- printf "8095" -}}
{{- end -}}

{{- define "vdp.internalTLS.pipelineBackend.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.pipelineBackend.secretName -}}
  {{- else -}}
    {{- printf "%s-pipeline-backend-internal-tls" (include "vdp.fullname" .) -}}
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
