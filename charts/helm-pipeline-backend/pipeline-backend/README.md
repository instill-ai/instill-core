# pipeline-backend

![Version: 1.0.7+238383e](https://img.shields.io/badge/Version-1.0.7+238383e-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

A Helm chart for Kubernetes to deploy the pipeline backend

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
| replicaCount | int | `1` | Number of instances to deploy for the pipeline backend deployment |
| imagePullSecrets | list | `[]` |  |
| image.registry | string | `registry.hub.docker.com/instill` | The image registry address |
| image.repository | string | `pipeline-backend` | The image repository name |
| image.tag | string | `latest` | The image tag |
| image.pullPolicy | string | `"IfNotPresent"` | The image pulling policy |
| deployment.config.server.port | int | `8081` | The server port |
| deployment.config.server.https.cert | string | `nil` | The http cert file path |
| deployment.config.server.https.key | string | `nil` | The http key file path |
| deployment.config.server.corsorigins | list | `["http://localhost:3000"]` | The corsorigin list |
| deployment.config.server.edition | string | `local-ce:dev` | The edition of backend |
| deployment.config.server.disableusage | bool | `true` | The disable usage flag |
| deployment.config.server.debug | bool | `false` | The debug flag |
| deployment.config.database.secret.name | string | `"db-user-pass"` | The database secret name |
| deployment.config.database.secret.usernamekey | string | `"username"` | The database secret username key |
| deployment.config.database.secret.passwordkey | string | `"password"` | The database secret password key |
| deployment.config.database.host | string | `"pg-sql-postgresql.pg-sql"` | The database host |
| deployment.config.database.port | int | `5432` | The database port |
| deployment.config.database.name | string | `pipeline` |  |
| deployment.config.connectorbackend.host | string | `"connector-backend.connector-backend"` | The connector backend host |
| deployment.config.connectorbackend.port | int | `8082` | The connector backend port |
| deployment.config.connectorbackend.https.cert | string | `nil` | The connector backend https cert file path |
| deployment.config.connectorbackend.https.key | string | `nil` | The connector backend https key file path |
| deployment.config.modelbackend.host | string | `"model-backend.model-backend"` | The model backend host |
| deployment.config.modelbackend.port | int | `8083` | The model backend port |
| deployment.config.modelbackend.https.cert | string | `nil` | The model backend https cert file path |
| deployment.config.modelbackend.https.key | string | `nil` | The model backend https key file path |
| deployment.config.mgmtbackend.host | string | `"mgmt-backend.mgmt-backend"` | The management backend host |
| deployment.config.mgmtbackend.port | int | `8084` | The management backend port |
| deployment.config.mgmtbackend.https.cert | string | `nil` | The management backend https cert file path |
| deployment.config.mgmtbackend.https.key | string | `nil` | The management backend https key file path |
| deployment.config.usagebackend.tlsenabled | bool | `true` | The usage service tls enable flag |
| deployment.config.usagebackend.host | string | `"usage.instill.tech"` | The usage service host |
| deployment.config.usagebackend.port | int | `443` | The usage service port |
| deployment.config.temporal.clientoptions.hostport | string | `"temporal-frontend.temporal:7233"` | The temporal host port |
| deployment.config.cache.redis.redisoptions.addr | string | `"redis-master.redis:6379"` | The redis host port |
| service.annotations | object | `{}` | The service annotation |
| service.port | int | `8081` | The service port |
| service.type | string | `"ClusterIP"` | The service type |
| podSecurityContext | object | `{}` | The pod security context |
| securityContext | object | `{}` | The security context |
| ingress.enabled | bool | `false` | Ingress enable/disable |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.hosts | list | `[]` | Ingress hosts |
| ingress.paths | list | `[]` | Ingress paths |
| ingress.pathType | string | `nil` | Ingress pathType |
| ingress.tls | list | `[{"hosts":[null],"secretName":null}]` | Ingress TLS certificates |
| strategy | object | `{}` | Strategy |
| resources | object | `{}` | Resources |
| autoscaling.enabled | bool | `false` | Autoscaling enable mode |
| autoscaling.maxReplicas | int | `100` | Autoscaling maximum replicas |
| autoscaling.minReplicas | int | `1` | Autoscaling minimun replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Autoscaling target CPU percentage |
| nodeSelector | object | `{}` | Node selector |
| tolerations | list | `[]` | Tolerations |
| affinity | object | `{}` | Affinity |
| podDisruptionBudget.enabled | bool | `false` | Pod disruption budget |
| podDisruptionBudget.spec.minAvailable | int | `1` | Pod disruption budget spec |
| sidecarContainers | object | `{}` | sidecar containers |
| podAnnotations | object | `{}` | Pod Annotations |
