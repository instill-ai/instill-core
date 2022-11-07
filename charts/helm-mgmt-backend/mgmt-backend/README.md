# mgmt-backend

![Version: 1.0.25](https://img.shields.io/badge/Version-1.0.25-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.6.6](https://img.shields.io/badge/AppVersion-1.6.6-informational?style=flat-square)

A Helm chart to deploy the mgmt backend on Kubernetes

- [Requirements](#requirements)
- [Deploy the Chart](#deploy-the-chart)
  - [Install](#install)
  - [Uninstall](#uninstall)
- [Chart values](#chart-values)

# Requirements

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
    mgmt \
    https://harbor.instill.tech/chartrepo/mgmt

# Update info of available charts
helm repo update

# Deploy the server
helm install \
    --username [harbor-username] \
    --password [harbor-cli-key] \
    [release-name] \
    mgmt/mgmt-backend
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
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal pod autoscaling configuration |
| deployment | object | `{"extraEnv":[],"extraInitContainers":{},"extraVolumeMounts":[],"extraVolumes":[],"livenessProbe":{},"readinessProbe":{}}` | Deployment |
| deployment.extraEnv | list | `[]` | If you want to add extra env variables |
| deployment.extraVolumes | list | `[]` | If you want to mount external volume For example, mount a secret containing Certificate root CA to verify database TLS connection. |
| deployment.livenessProbe | object | `{}` | LivenessProbe httpGet:   path: /live   port: 3000   initialDelaySeconds: 40   periodSeconds: 10 |
| deployment.readinessProbe | object | `{}` | ReadynessProbe httpGet:   path: /ready   port: 3000   initialDelaySeconds: 3   periodSeconds: 5 |
| fullnameOverride | string | `nil` | String to fully override common.names.fullname |
| image | object | `{"pullPolicy":"IfNotPresent","registry":null,"repository":null,"tag":null}` | mgmt-backend image version |
| image.pullPolicy | string | `"IfNotPresent"` | The image pulling policy |
| image.registry | string | `nil` | mgmt-backend image registry |
| image.repository | string | `nil` | mgmt-backend image name |
| image.tag | string | `nil` | mgmt-backend image tag, default is the chart appVersion |
| imagePullSecrets | list | `[]` | secret to pull docker images |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[],"tls":[]}` | Ingress |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.className | string | `""` | Ingress class name |
| ingress.enabled | bool | `false` | Ingress enable/disable |
| job | object | `{"annotations":{},"ttlSecondAfterFinished":300}` | Values for initalization job |
| mgmt | object | `{"config":{"hydra":{"admin":{"url":null},"audience":null,"issuer":"https://instill.tech/","public":{"url":null},"ttl":{"access_token":"24h"}},"kratos":{"admin":{"url":null}},"server":{"allowed_audiences":[],"cors":{"headers":["Jwt-Sub","Jwt-Client-Id","Jwt-Iss","Jwt-Aud","Jwt-Scope","Jwt-Models","X-Forwarded-For","Request-Id","Authorization"],"origins":["https://instill-inc.tech","https://instill.tech","https://*.instill-inc.tech","https://*.instill.tech"]},"port":8444,"tls":{"cert":"/ssl/tls.crt","key":"/ssl/tls.key"}}}}` | mgmt-backend configuration |
| mgmt.config | object | `{"hydra":{"admin":{"url":null},"audience":null,"issuer":"https://instill.tech/","public":{"url":null},"ttl":{"access_token":"24h"}},"kratos":{"admin":{"url":null}},"server":{"allowed_audiences":[],"cors":{"headers":["Jwt-Sub","Jwt-Client-Id","Jwt-Iss","Jwt-Aud","Jwt-Scope","Jwt-Models","X-Forwarded-For","Request-Id","Authorization"],"origins":["https://instill-inc.tech","https://instill.tech","https://*.instill-inc.tech","https://*.instill.tech"]},"port":8444,"tls":{"cert":"/ssl/tls.crt","key":"/ssl/tls.key"}}}` | Config file |
| mgmt.config.hydra | object | `{"admin":{"url":null},"audience":null,"issuer":"https://instill.tech/","public":{"url":null},"ttl":{"access_token":"24h"}}` | Hydra configuration |
| mgmt.config.hydra.admin | object | `{"url":null}` | Hydra admin service configuration |
| mgmt.config.hydra.admin.url | string | `nil` | Hydra admin service internal DNS |
| mgmt.config.hydra.audience | string | `nil` | 'aud' claim in Token, should be the API url by default |
| mgmt.config.hydra.issuer | string | `"https://instill.tech/"` | 'iss' claim in Token |
| mgmt.config.hydra.public | object | `{"url":null}` | Hydra public service |
| mgmt.config.hydra.public.url | string | `nil` | Hydra public service internal DNS |
| mgmt.config.hydra.ttl | object | `{"access_token":"24h"}` | Hydra time to live configuration |
| mgmt.config.hydra.ttl.access_token | string | `"24h"` | How long access tokens are valid |
| mgmt.config.kratos | object | `{"admin":{"url":null}}` | Kratos configuration |
| mgmt.config.kratos.admin | object | `{"url":null}` | Kratos admin service configuration |
| mgmt.config.kratos.admin.url | string | `nil` | Kratos admin service internal DNS |
| mgmt.config.server | object | `{"allowed_audiences":[],"cors":{"headers":["Jwt-Sub","Jwt-Client-Id","Jwt-Iss","Jwt-Aud","Jwt-Scope","Jwt-Models","X-Forwarded-For","Request-Id","Authorization"],"origins":["https://instill-inc.tech","https://instill.tech","https://*.instill-inc.tech","https://*.instill.tech"]},"port":8444,"tls":{"cert":"/ssl/tls.crt","key":"/ssl/tls.key"}}` | mgmt-backend server configuration |
| mgmt.config.server.allowed_audiences | list | `[]` | Allowed audience list when requesting a client token. Here we add 'instill.tech/management' and 'instill.tech/inference' for back compatibility. |
| mgmt.config.server.cors | object | `{"headers":["Jwt-Sub","Jwt-Client-Id","Jwt-Iss","Jwt-Aud","Jwt-Scope","Jwt-Models","X-Forwarded-For","Request-Id","Authorization"],"origins":["https://instill-inc.tech","https://instill.tech","https://*.instill-inc.tech","https://*.instill.tech"]}` | CORS configuration |
| mgmt.config.server.cors.headers | list | `["Jwt-Sub","Jwt-Client-Id","Jwt-Iss","Jwt-Aud","Jwt-Scope","Jwt-Models","X-Forwarded-For","Request-Id","Authorization"]` | CORS allowed headers |
| mgmt.config.server.cors.origins | list | `["https://instill-inc.tech","https://instill.tech","https://*.instill-inc.tech","https://*.instill.tech"]` | CORS allowed origins |
| mgmt.config.server.port | int | `8444` | Internal cluster port through which the mgmt backend server can be queried |
| mgmt.config.server.tls.cert | string | `"/ssl/tls.crt"` | TLS certificate file path |
| mgmt.config.server.tls.key | string | `"/ssl/tls.key"` | TLS key file path |
| nameOverride | string | `nil` | String to partially override common.names.fullname |
| nodeSelector | object | `{}` | Pod nodeSelector |
| pdb | object | `{"enabled":false,"spec":{"minAvailable":1}}` | PodDistributionBudget |
| pdb.spec.minAvailable | int | `1` | Minimal number of available pods |
| podAnnotations | object | `{}` | Additional deployment annotations |
| podSecurityContext | object | `{}` | Security context for mgmt backend pods fsGroup: 2000 |
| replicaCount | int | `1` | Number of instances to deploy for the server deployment |
| resources | object | `{}` | Resource assigned to the mgmt backend server. We usually recommend not to specify default resources and to leave this as a conscious choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. If you do want to specify resources, uncomment the following lines, adjust them as necessary, and remove the curly braces after 'resources:'. limits:   cpu: 100m   memory: 128Mi requests:   cpu: 100m   memory: 128Mi |
| securityContext | object | `{}` | Security context for mgmt backend containers capabilities:   drop:   - ALL readOnlyRootFilesystem: true runAsNonRoot: true runAsUser: 1000 |
| service | object | `{"annotations":{},"port":8444,"type":"ClusterIP"}` | Service |
| service.port | int | `8444` | Port of the mgmt backend server. |
| service.type | string | `"ClusterIP"` | Kubernetes service type |
| serviceAccountName | string | `"default"` | service account name |
| strategy | object | `{}` | Strategy used to replace old pods by new ones |
| tolerations | list | `[]` | Pod tolerations |
