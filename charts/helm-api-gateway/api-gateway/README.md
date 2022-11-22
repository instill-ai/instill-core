# api-gateway

![Version: 1.5.2](https://img.shields.io/badge/Version-1.5.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.15.2](https://img.shields.io/badge/AppVersion-1.15.2-informational?style=flat-square)

A Helm chart to deploy the Krakend API Gateway

- [Requirements](#requirements)
- [Deploy the Chart](#deploy-the-chart)
  - [Install](#install)
  - [Uninstall](#uninstall)
- [Chart values](#chart-values)

### Caution
> :warning: If deploying with `terraform-on-prem-dgx-common` on `g0` with `debug.enabled=true`, remember to keep the KrakenD configuration file `config/krakend-g0.json`up to the version for testing.

# Requirements

This Helm chart uses [cert-manager](https://cert-manager.io) for TLS certificate management. Please make sure cert-manager has been deployed on the target Kubernetes cluster.

# Deploy the Chart

## Install
The Helm Chart can be installed from source or from a repository.

Install from source:
```bash
cd [directory-containing-Chart.yaml]

# Render the templates and return the manifest file
helm install --debug --dry-run [release-name] .

# Deploy the server
helm install [release-name] .
```

Install from a repository (e.g our Harbor repository):
```bash
# Add Harbor project as separate index entry point
helm repo add \
    --username [harbor-username] \
    --password [harbor-cli-key] \
    <HARBOR PROJECT NAME> \
    https://harbor.instill.tech/chartrepo/<HARBOR PROJECT NAME>

# Update info of available charts
helm repo update

# Deploy the server
helm install \
    --username [harbor-username] \
    --password [harbor-cli-key] \
    [release-name] \
    <HARBOR PROJECT NAME>/api-gateway
```

## Uninstall

To remove the deployed server:

```bash
helm uninstall [release-name]
```

# Chart values

The following table lists the configurable parameters of the Helm Chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nameOverride | string | `nil` | Name to override |
| fullnameOverride | string | `nil` | Full name to override |
| replicaCount | int | `1` | Number of instances to deploy for the KrakenD API Gateway deployment |
| imagePullSecrets | list | `[]` |  |
| image.registry | string | `registry.hub.docker.com/instill` | The image registry address |
| image.repository | string | `connector-backend` | The image repository name |
| image.tag | string | `latest` | The image tag |
| image.pullPolicy | string | `"IfNotPresent"` | The image pulling policy |
| debug.enabled | bool | `false` | Enable KrakenD debug mode |
| ingress.enabled | bool | `false` | Ingress enable/disable |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.hosts | list | `[]` | Ingress hosts |
| ingress.paths | list | `[]` | Ingress paths |
| ingress.pathType | string | `nil` | Ingress pathType |
| ingress.tls | list | `[{"hosts":[null],"secretName":null}]` | Ingress TLS certificates |
| service.annotations | object | `{}` | Service annotations |
| service.type | string | `"NodePort"` | Service type |
| service.nodePortHttp | int | `30100` | NodePort for https port |
| service.nodePortStats | int | `30101` | NodePort for stats port |
| service.nodePortMetrics | int | `30102` | NodePort for metrics port |
| strategy | object | `{}` | The strategy used to replace old Pods by new ones, which can be "Recreate" or "RollingUpdate". "RollingUpdate" is the default value. |
| resources | object | `{}` | Resources assigned to the API Gateway. This is left empty by default to allow the user to configure it at install time. Resources should not be hardcoded here, but specified at install time to provide flexibility |
| nodeSelector | object | `{}` | Pod nodeSelector |
| tolerations | list | `[]` | Pod tolerations |
| affinity | object | `{}` | Pod affinity |
| podAnnotations | object | `{}` | Additional deployment annotations |
| apiGateway.host | string | `nil` |  |
| apiGateway.port.http | int | `8000` |  |
| apiGateway.port.metrics | int | `9000` |  |
| apiGateway.port.stats | int | `8090` |  |
| apiGateway.https.cert | string | `nil` |  |
| apiGateway.https.key | string | `nil` |  |
| mgmtBackend.host | string | `nil` |  |
| mgmtBackend.port | int | `8084` |  |
| mgmtBackend.https.cert | string | `nil` |  |
| mgmtBackend.https.key | string | `nil` |  |
| modelBackend.host | string | `nil` |  |
| modelBackend.port | int | `8085` |  |
| modelBackend.https.cert | string | `nil` |  |
| modelBackend.https.key | string | `nil` |  |
| pipelineBackend.host | string | `nil` |  |
| pipelineBackend.port | int | `8083` |  |
| pipelineBackend.https.cert | string | `nil` |  |
| pipelineBackend.https.key | string | `nil` |  |
| connectorBackend.host | string | `nil` |  |
| connectorBackend.port | int | `8082` |  |
| connectorBackend.https.cert | string | `nil` |  |
| connectorBackend.https.key | string | `nil` |  |









