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
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| config.cache.redis.redisoptions.addr | string | `"localhost:6379"` |  |
| config.database.databasename | string | `"connectors"` |  |
| config.database.host | string | `"192.168.1.92"` |  |
| config.database.password | string | `"instillpw"` |  |
| config.database.pool.connlifetime | int | `30` |  |
| config.database.pool.idleconnections | int | `5` |  |
| config.database.pool.maxconnections | int | `10` |  |
| config.database.port | int | `3306` |  |
| config.database.username | string | `"root"` |  |
| config.modelbackend.host | string | `"model-backend.instill-model-backend"` |  |
| config.modelbackend.port | int | `8445` |  |
| config.modelbackend.scheme | string | `"https"` |  |
| config.modelservice.host | string | `"model-backend.instill-model-backend"` |  |
| config.modelservice.port | int | `8445` |  |
| config.modelservice.tls | bool | `false` |  |
| config.server.cors-origins[0] | string | `"http://localhost"` |  |
| config.server.cors-origins[1] | string | `"https://instill-inc.tech"` |  |
| config.server.cors-origins[2] | string | `"https://instill.tech"` |  |
| config.server.https.cert | string | `"/ssl/tls.crt"` |  |
| config.server.https.enabled | bool | `false` |  |
| config.server.https.key | string | `"/ssl/tls.key"` |  |
| config.server.paginate.salt | string | `"4N4ZgKp9gCtNkUR3"` |  |
| config.server.port | int | `8080` |  |
| config.temporal.clientoptions.hostport | string | `"temporal-frontend-headless.temporal.svc.cluster.local.:7233"` |  |
| config.temporal.clientoptions.namespace | string | `"connector"` |  |
| config.vdo.host | string | `"inference-backend.instill-inference-backend.svc.cluster.local."` |  |
| config.vdo.path | string | `"inference/models/%s/versions/%s/outputs"` |  |
| config.vdo.port | int | `8443` |  |
| config.vdo.scheme | string | `"https"` |  |
| fullnameOverride | string | `nil` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.registry | string | `nil` |  |
| image.repository | string | `nil` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.tls | list | `[]` |  |
| job.extraEnv | object | `{}` |  |
| nameOverride | string | `nil` |  |
| nodeSelector | object | `{}` |  |
| persistence.existingSecret | string | `nil` |  |
| podAnnotations | object | `{}` |  |
| podDisruptionBudget.enabled | bool | `false` |  |
| podDisruptionBudget.spec.minAvailable | int | `1` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.annotations | object | `{}` |  |
| service.port | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccountName | string | `"default"` |  |
| sidecarContainers | object | `{}` |  |
| strategy | object | `{}` |  |
| tolerations | list | `[]` |  |
