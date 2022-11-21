# connector-backend

![Version: 1.0.7+238383e](https://img.shields.io/badge/Version-1.0.7+238383e-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

A Helm chart for Kubernetes to deploy the connector backend

- [Requirements](#requirements)
- [Deploy the Chart](#deploy-the-chart)
  - [Install](#install)
  - [Uninstall](#uninstall)
- [Chart values](#chart-values)

# Requirements

This Helm chart uses [cert-manager](https://cert-manager.io) for TLS certificate management. Please make sure cert-manager has been deployed on the target Kubernetes cluster.

| Repository | Name | Version |
|------------|------|---------|

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
    inference \
    https://harbor.instill.tech/chartrepo/inference

# Update info of available charts
helm repo update

# Deploy the server
helm install \
    --username [harbor-username] \
    --password [harbor-cli-key] \
    [release-name] \
    inference/connector-backend
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
| image.registry | string | `registry.hub.docker.com/instill` | The image registry address |
| image.repository | string | `connector-backend` | The image repository name |
| image.tag | string | `latest` | The image tag |
| image.pullPolicy | string | `"IfNotPresent"` | The image pulling policy |
| deployment.config.server.port | int | `8082` |  |
| deployment.config.server.https.cert | string | `nil` |  |
| deployment.config.server.https.key | string | `nil` |  |
| deployment.config.server.corsorigins | list | `[]` |  |
| deployment.config.server.edition | string | `local-ce:dev` |  |
| deployment.config.server.disableusage | bool | `true` |  |
| deployment.config.server.debug | bool | `false` |  |
| deployment.config.worker.mountsource.vdp | string | `vdp` |  |
| deployment.config.worker.mountsource.airbyte | string | `airbyte` |  |
| deployment.config.database.secret.name | string | `"db-user-pass"` |  |
| deployment.config.database.secret.usernamekey | string | `"username"` |  |
| deployment.config.database.secret.passwordkey | string | `"password"` |  |
| deployment.config.database.host | string | `"pg-sql-postgresql.pg-sql"` |  |
| deployment.config.database.password | string | `"5432"` |  |
| deployment.config.database.pool.connlifetime | int | `30` |  |
| deployment.config.database.pool.idleconnections | int | `5` |  |
| deployment.config.database.pool.maxconnections | int | `10` |  |
| deployment.config.database.port | int | `5432` |  |
| deployment.config.database.name | string | `connector` |  |
| deployment.config.pipelinebackend.host | string | `"pipeline-backend.pipeline-backend"` |  |
| deployment.config.pipelinebackend.port | int | `8081` |  |
| deployment.config.pipelinebackend.https.cert | string | `nil` |  |
| deployment.config.pipelinebackend.https.key | string | `nil` |  |
| deployment.config.mgmtbackend.host | string | `"mgmt-backend.mgmt-backend"` |  |
| deployment.config.mgmtbackend.port | int | `8084` |  |
| deployment.config.mgmtbackend.https.cert | string | `nil` |  |
| deployment.config.mgmtbackend.https.key | string | `nil` |  |
| deployment.config.usagebackend.tlsenabled | bool | `true` |  |
| deployment.config.usagebackend.host | string | `"usage.instill.tech"` |  |
| deployment.config.usagebackend.port | int | `443` |  |
| deployment.config.temporal.clientoptions.hostport | string | `"temporal-frontend.temporal:7233"` |  |
| service.annotations | object | `{}` |  |
| service.port | int | `8081` |  |
| service.type | string | `"ClusterIP"` |  |
| podSecurityContext | object | `{}` |  |
| securityContext | object | `{}` |  |
| ingress.enabled | bool | `false` | Ingress enable/disable |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.hosts | list | `[]` | Ingress hosts |
| ingress.paths | list | `[]` | Ingress paths |
| ingress.pathType | string | `nil` | Ingress pathType |
| ingress.tls | list | `[{"hosts":[null],"secretName":null}]` | Ingress TLS certificates |
| strategy | object | `{}` |  |
| resources | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| nodeSelector | object | `{}` |  |
| tolerations | list | `[]` |  |
| affinity | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| sidecarContainers | object | `{}` |  |
| podDisruptionBudget.enabled | bool | `false` |  |
| podDisruptionBudget.spec.minAvailable | int | `1` |  |






