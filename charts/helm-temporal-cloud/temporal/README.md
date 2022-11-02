# temporal

![Version: 1.1.4](https://img.shields.io/badge/Version-1.1.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

A Helm chart to deploy the temporal backend server on Kubernetes

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
    <HARBOR PROJECT NAME> \
    https://harbor.instill.tech/chartrepo/<HARBOR PROJECT NAME>

# Update info of available charts
helm repo update

# Deploy the server
helm install \
    --username [harbor-username] \
    --password [harbor-cli-key] \
    [release-name] \
    <HARBOR PROJECT NAME>/temporal
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
| corsAllow | list | `["http://localhost:3000","https://api.instill-inc.tech","https://api.instill.tech","https://api-d2.instill.tech"]` | CORS-allowed source URLs |
| db.dns.name | string | `"gcloud-sqlproxy"` | Name of the Kubernetes service linked to the deployed Triton server. This is used for DNS resolution. This is only used if `tritonService.ip` is not provided. |
| db.dns.namespace | string | `"gcloud-sqlproxy"` | Namespace under which the Triton server is deployed |
| db.name | string | `"temporals"` | SQL database name |
| db.password | string | `nil` | [Required to set] Password for the `root` user. (10 character alphanumeric string) |
| db.port | int | `3308` | MySQL Primary K8s service port |
| db.username | string | `nil` | [Required to set] Database username |
| db.version | int | `1` | SQL database version for mgirating |
| fullnameOverride | string | `nil` | String to fully override common.names.fullname |
| harbor.password | string | `nil` | [Required to set] The Harbor password for login |
| harbor.username | string | `nil` | [Required to set] The Harbor username for login |
| http.enabled | bool | `false` | If enabled, the server will be launched with HTTP. Both HTTP and HTTPS cannot be enabled at the same time. |
| http.port | int | `8080` | HTTP port (container port) |
| https.enabled | bool | `true` | If enabled, the server will be launched with HTTPS. Both HTTP and HTTPS cannot be enabled at the same time. |
| https.port | int | `8445` | HTTPS port (container port) |
| image.containerPort | int | `8445` | Internal cluster port through which the temporal backend server can be queried |
| image.livenessProbe | object | `{}` | LivenessProbe httpGet:   path: /live   port: 3000   initialDelaySeconds: 40   periodSeconds: 10 |
| image.pullPolicy | string | `"Always"` | The image pulling policy |
| image.readinessProbe | object | `{}` | ReadynessProbe httpGet:   path: /ready   port: 3000   initialDelaySeconds: 3   periodSeconds: 5 |
| image.registry | string | `"europe-west2-docker.pkg.dev/prj-c-devops-artifacts-a306/temporal"` | temporal backend image registry |
| image.repository | string | `"temporal"` | temporal backend image name |
| image.tag | string | `nil` | temporal backend image tag, default is the chart appVersion |
| nameOverride | string | `nil` | String to partially override common.names.fullname |
| nodeSelector | object | `{}` | Pod nodeSelector |
| podAnnotations | object | `{}` | Additional deployment annotations |
| podSecurityContext | object | `{}` | Security context for temporal backend pods fsGroup: 2000 |
| replicaCount | int | `1` | Number of instances to deploy for the server deployment |
| resources | object | `{}` | Resource assigned to the temporal backend server. We usually recommend not to specify default resources and to leave this as a conscious choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. If you do want to specify resources, uncomment the following lines, adjust them as necessary, and remove the curly braces after 'resources:'. limits:   cpu: 100m   memory: 128Mi requests:   cpu: 100m   memory: 128Mi |
| securityContext | object | `{}` | Security context for temporal backend containers capabilities:   drop:   - ALL readOnlyRootFilesystem: true runAsNonRoot: true runAsUser: 1000 |
| service.nodePort | int | `31300` | NodePort of the temporal backend server. Only valid when `service.type=NodePort`. If not specified, the NodePort is randomly assigned from a range (default: 30000-32767) by Kubernetes |
| service.port | int | `8445` | Port of the temporal backend server. |
| service.type | string | `"NodePort"` | Kubernetes service type |
| serviceAccountName | string | `"default"` |  |
| tolerations | list | `[]` | Pod tolerations |
| tritonBackendService.dns.name | string | `"triton-backend"` | Name of the Kubernetes service linked to the deployed Triton server. This is used for DNS resolution. This is only used if `tritonService.ip` is not provided. |
| tritonBackendService.dns.namespace | string | `"triton-backend"` | Namespace under which the Triton server is deployed |
| tritonBackendService.grpcPort | int | `8001` | Internal cluster port through which the Triton server can be queried through gRPC |
| tritonBackendService.httpPort | int | `8000` | Internal cluster port through which the Triton server can be queried through HTTP |
| tritonBackendService.ip | string | `nil` | IP address for the deployed Triton server. If non-empty, the IP address will be used to communicate with the Triton service instead of `tritonService.dns` |
| userMgmtService.dns.name | string | `"kratos-admin"` | Name of the Kubernetes service linked to the deployed User Management service. This is used for DNS resolution. This is only used if `tritonService.ip` is not provided. |
| userMgmtService.dns.namespace | string | `"kratos"` | Namespace under which the Triton server is deployed |
| userMgmtService.httpPort | int | `8000` | Internal cluster port through which the Triton server can be queried through HTTP |
| userMgmtService.ip | string | `nil` | IP address for the deployed Triton server. If non-empty, the IP address will be used to communicate with the Triton service instead of `tritonService.dns` |
