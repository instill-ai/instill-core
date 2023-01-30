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
{{- define "vdp.chart.version" -}}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vdp.app.version" -}}
{{- printf "%s" .Chart.AppVersion | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "vdp.labels" -}}
release: {{ .Release.Name }}
chart: {{ .Chart.Name }}
app: {{ template "vdp.name" . }}
{{- end -}}

{{/*
MatchLabels
*/}}
{{- define "vdp.matchLabels" -}}
release: {{ .Release.Name }}
app: {{ template "vdp.name" . }}
{{- end -}}

{{- define "vdp.edition" -}}
{{- printf "kubernetes-ce" -}}
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

{{- define "vdp.database.host" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- template "vdp.database" . -}}
  {{- else -}}
    {{- .Values.database.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "vdp.database.port" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "5432" -}}
  {{- else -}}
    {{- .Values.database.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "vdp.database.username" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "postgres" -}}
  {{- else -}}
    {{- .Values.database.external.username -}}
  {{- end -}}
{{- end -}}

{{- define "vdp.database.rawPassword" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- .Values.database.internal.password -}}
  {{- else -}}
    {{- .Values.database.external.password -}}
  {{- end -}}
{{- end -}}

{{- define "vdp.database.encryptedPassword" -}}
  {{- include "vdp.database.rawPassword" . | b64enc | quote -}}
{{- end -}}

{{- define "vdp.redis.scheme" -}}
  {{- with .Values.redis -}}
    {{- ternary "redis+sentinel" "redis"  (and (eq .type "external" ) .external.sentinelMasterSet) -}}
  {{- end -}}
{{- end -}}

/*host:port*/
{{- define "vdp.redis.addr" -}}
  {{- with .Values.redis -}}
    {{- ternary (printf "%s:6379" (include "vdp.redis" $ )) .external.addr (eq .type "internal") -}}
  {{- end }}
{{- end -}}

{{- define "vdp.redis.masterSet" -}}
  {{- with .Values.redis -}}
    {{- ternary .external.sentinelMasterSet "" (eq "redis+sentinel" (include "vdp.redis.scheme" $)) -}}
  {{- end -}}
{{- end -}}

{{- define "vdp.redis.password" -}}
  {{- with .Values.redis -}}
    {{- ternary "" .external.password (eq .type "internal") -}}
  {{- end -}}
{{- end -}}

/*scheme://[:password@]host:port[/master_set]*/
{{- define "vdp.redis.url" -}}
  {{- with .Values.redis -}}
    {{- $path := ternary "" (printf "/%s" (include "vdp.redis.masterSet" $)) (not (include "vdp.redis.masterSet" $)) -}}
    {{- $cred := ternary (printf ":%s@" (.external.password | urlquery)) "" (and (eq .type "external" ) (not (not .external.password))) -}}
    {{- printf "%s://%s%s%s" (include "vdp.redis.scheme" $) $cred (include "vdp.redis.addr" $) $path -}}
  {{- end -}}
{{- end -}}

{{- define "vdp.apigateway" -}}
  {{- printf "%s-apigateway" (include "vdp.fullname" .) -}}
{{- end -}}

{{- define "vdp.pipeline" -}}
  {{- printf "%s-pipeline" (include "vdp.fullname" .) -}}
{{- end -}}

{{- define "vdp.pipeline.migration" -}}
  {{- printf "%s-migration" (include "vdp.pipeline" .) -}}
{{- end -}}

{{- define "vdp.connector" -}}
  {{- printf "%s-connector" (include "vdp.fullname" .) -}}
{{- end -}}

{{- define "vdp.connector.migration" -}}
  {{- printf "%s-migration" (include "vdp.connector" .) -}}
{{- end -}}

{{- define "vdp.connector.worker" -}}
  {{- printf "%s-worker" (include "vdp.connector" .) -}}
{{- end -}}

{{- define "vdp.model" -}}
  {{- printf "%s-model" (include "vdp.fullname" .) -}}
{{- end -}}

{{- define "vdp.model.migration" -}}
  {{- printf "%s-migration" (include "vdp.model" .) -}}
{{- end -}}

{{- define "vdp.model.worker" -}}
  {{- printf "%s-worker" (include "vdp.model" .) -}}
{{- end -}}

{{- define "vdp.mgmt" -}}
  {{- printf "%s-mgmt" (include "vdp.fullname" .) -}}
{{- end -}}

{{- define "vdp.mgmt.migration" -}}
  {{- printf "%s-migration" (include "vdp.mgmt" .) -}}
{{- end -}}

{{- define "vdp.console" -}}
  {{- printf "%s-console" (include "vdp.fullname" .) -}}
{{- end -}}

{{- define "vdp.database" -}}
  {{- printf "%s-database" (include "vdp.fullname" .) -}}
{{- end -}}

{{- define "vdp.redis" -}}
  {{- printf "%s-redis" (include "vdp.fullname" .) -}}
{{- end -}}

{{/* scheme for all components */}}
{{- define "vdp.component.scheme" -}}
  {{- if .Values.internalTLS.enabled -}}
    {{- printf "https" -}}
  {{- else -}}
    {{- printf "http" -}}
  {{- end -}}
{{- end -}}

{{/* api-gateway service and container port */}}
{{- define "vdp.apigateway.port" -}}
  {{- printf "8080" -}}
{{- end -}}

{{/* pipeline service and container port */}}
{{- define "vdp.pipeline.port" -}}
  {{- printf "8081" -}}
{{- end -}}

{{/* connector service and container port */}}
{{- define "vdp.connector.port" -}}
  {{- printf "8082" -}}
{{- end -}}

{{/* model service and container port */}}
{{- define "vdp.model.port" -}}
  {{- printf "8083" -}}
{{- end -}}

{{/* mgmt service and container port */}}
{{- define "vdp.mgmt.port" -}}
  {{- printf "8084" -}}
{{- end -}}

{{/* console service and container port */}}
{{- define "vdp.console.port" -}}
  {{- printf "3000" -}}
{{- end -}}

{{- define "vdp.internalTLS.apigateway.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.apigateway.secretName -}}
  {{- else -}}
    {{- printf "%s-apigateway-internal-tls" (include "vdp.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{- define "vdp.internalTLS.pipeline.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.pipeline.secretName -}}
  {{- else -}}
    {{- printf "%s-pipeline-internal-tls" (include "vdp.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{- define "vdp.internalTLS.connector.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.connector.secretName -}}
  {{- else -}}
    {{- printf "%s-connector-internal-tls" (include "vdp.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{- define "vdp.internalTLS.model.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.model.secretName -}}
  {{- else -}}
    {{- printf "%s-model-internal-tls" (include "vdp.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{- define "vdp.internalTLS.mgmt.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.mgmt.secretName -}}
  {{- else -}}
    {{- printf "%s-mgmt-internal-tls" (include "vdp.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{- define "vdp.internalTLS.console.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.console.secretName -}}
  {{- else -}}
    {{- printf "%s-console-internal-tls" (include "vdp.fullname" .) -}}
  {{- end -}}
{{- end -}}
