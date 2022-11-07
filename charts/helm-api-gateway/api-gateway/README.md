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
| affinity | object | `{}` | Pod affinity |
| apiGateway.host | string | `nil` |  |
| apiGateway.port.https | int | `8000` |  |
| apiGateway.port.metrics | int | `9000` |  |
| apiGateway.port.stats | int | `8090` |  |
| cloudflareOriginCaKey | string | `nil` | Kubernetes secret name in which the Cloudflare Origin CA Key |
| debug.enabled | bool | `false` | Enable KrakenD debug mode |
| fullnameOverride | string | `nil` | Full name to override |
| httpsPort | int | `8000` | Internal container port through which the KrakenD can be accessed |
| hydra.audience | string | `nil` | 'audience' claim of the access token issued by Hydra. By default it is set to the Instill API url |
| hydra.issuer | string | `"https://instill.tech/"` | 'issuer' claim of the token issued by Hydra. By default it is set to 'https://instill.tech/' |
| hydra.publicDomain | string | `nil` | Hydra public service domain |
| image.pullPolicy | string | `"Always"` | The image pulling policy |
| image.registry | string | `nil` | The image registry address |
| image.repository | string | `nil` | The image repository name |
| image.tag | string | `nil` | The image tag |
| inferenceBackend.host | string | `nil` |  |
| inferenceBackend.port.https | int | `8443` |  |
| influxDB.host | string | `nil` |  |
| influxDB.port.https | int | `8086` |  |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.enabled | bool | `false` | Ingress enable/disable |
| ingress.hosts | list | `[]` | Ingress hosts |
| ingress.pathType | string | `nil` | Ingress pathType |
| ingress.paths | list | `[]` | Ingress paths |
| ingress.tls | list | `[{"hosts":[null],"secretName":null}]` | Ingress TLS certificates |
| metricsPort | int | `9000` | Internal container port through which Prometheus can scrape KrakenD metrics |
| mgmtBackend.host | string | `nil` |  |
| mgmtBackend.port.https | int | `8444` |  |
| modelBackend.host | string | `nil` |  |
| modelBackend.port.https | int | `8445` |  |
| nameOverride | string | `nil` | Name to override |
| nodeSelector | object | `{}` | Pod nodeSelector |
| pipelineBackend.host | string | `nil` |  |
| pipelineBackend.port.https | int | `8443` |  |
| podAnnotations | object | `{}` | Additional deployment annotations |
| replicaCount | int | `1` | Number of instances to deploy for the KrakenD API Gateway deployment |
| resources | object | `{}` | Resources assigned to the API Gateway. This is left empty by default to allow the user to configure it at install time. Resources should not be hardcoded here, but specified at install time to provide flexibility |
| service.annotations | object | `{}` | Service annotations |
| service.nodePortHttps | int | `30100` | NodePort for https port |
| service.nodePortMetrics | int | `30102` | NodePort for metrics port |
| service.nodePortStats | int | `30101` | NodePort for stats port |
| service.type | string | `"NodePort"` | Service type |
| statsPort | int | `8090` | Internal container port through which the KrakenD stats can be accessed |
| strategy | object | `{}` | The strategy used to replace old Pods by new ones, which can be "Recreate" or "RollingUpdate". "RollingUpdate" is the default value. |
| tolerations | list | `[]` | Pod tolerations |
