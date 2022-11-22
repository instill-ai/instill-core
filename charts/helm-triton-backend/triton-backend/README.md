# triton-backend

![Version: 1.3.0](https://img.shields.io/badge/Version-1.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.4.0](https://img.shields.io/badge/AppVersion-1.4.0-informational?style=flat-square)

Triton Inference Server

- [Introduction](#introduction)
- [Deployment](#deployment)
  - [KIND cluster configuration](#kind-cluster-configuration)
  - [Model repository](#model-repository)
    - [Locally accessible filesystem](#locally-accessible-filesystem)
  - [Installing the Chart](#installing-the-chart)
    - [Pull images from a private registry](#pull-images-from-a-private-registry)
    - [Deploy Triton inference server](#deploy-triton-inference-server)
      - [Install from source](#install-from-source)
      - [Install from repository](#install-from-repository)
  - [Use the inference server](#use-the-inference-server)
  - [Uninstalling the Chart](#uninstalling-the-chart)
- [Values](#values)

## Introduction
This chart installs a [NVIDIA Triton
Inference Server](https://github.com/NVIDIA/triton-inference-server) on a Kubernetes cluster using Helm package manager. By default the cluster contains a single instance of the inference server but the *replicaCount* configuration parameter can be set to create a cluster of any size, as described below. This guide assumes you already have a functional Kubernetes
cluster and helm installed. If you want Triton Server to use GPUs for inferencing, your cluster must be configured with support for the NVIDIA driver and CUDA version required by the version of the inference server you are using.

The steps below describe how to use helm to launch the inference server.

## Deployment
The steps below describe how to use helm to launch the inference server and then send inference requests to the running server.
>:information_source: Read [KIND cluster configuration](#kind-cluster-configuration) if you are deploying on a kinD cluster.

### KIND cluster configuration
If you are deploying on a kinD cluster, you need to configure the kinD cluster creation:
 - Extra mounts: mount the model repository from host machine to the kinD cluster with `extraMount`
 - Extra port mapping to expose a `NodePort` service: map ports to the host machine with `extraPortMappings` to get traffic into the kinD cluster

Here, we provide a yaml config file as an example:
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraMounts:
  - hostPath: [model_repository_on_host]
    containerPath: [model_repository_on_kind]
  extraPortMappings:
  - containerPort: [http_nodeport]
    hostPort: [http_nodeport]
    protocol: TCP
  - containerPort: [grpc_nodeport]
    hostPort: [grpc_nodeport]
    protocol: TCP
  - containerPort: [metrics_nodePort]
    hostPort: [metrics_nodePort]
    protocol: TCP
```
where
- `model_repository_on_host` points to the model directory that stores models on the host machine
- `model_repository_on_kind` is the value of `image.modelRepositoryPath` in `single_server/values.yaml`, kinD mounts `model_repository_on_host` from host machine to `model_repository_on_kind` on the kinD cluster
- `http_nodeport` is the nodeport of the HTTP endpoint
- `grpc_nodeport` is the nodeport of the gRPC endpoint
- `metrics_nodeport` is the nodeport of the inference server metrics endpoint

### Model repository
Triton inference server needs a repository of models that it will make available for inferencing. The repository path is specified when Triton is started using `--model-store` or `--model-repository` option.

You can place the model repository in
- [**for now**] local accessible filesystem: models are stored under `/models` by default
- Google Cloud Storage
- Amazon S3

#### Locally accessible filesystem
For now, we use a [`hostPath`](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath) volume to mount the directory from host nodes's filesystem into `/models` of the container. Config `image.modelRepositoryPath` in `single_server/values.yaml` to point to the local directory on the host node.

>:information_source: `hostPath` volume is **NOT** recommended and will be improved in the future:
> - The Pod is tightly coupled to the underlying volume and the node. It is against the Kubernetes principle: workload portability.
> - The server is run as non-root user (user `1000` from group `1000`). The files or directories created on the underlying hosts are only writable by root. You either need to run your process as root in a privileged Container or modify the file permissions on the host to be able to write to a `hostPath` volume.

### Installing the Chart

##### Install from source
To install the chart with the release name `example`:
```bash
$ helm dependency update  # retrieve dependent charts into charts/ directory
$ helm install example .  # deploy the server
```

The Triton inference server exposes both HTTP and GRPC based on KFServing standard inference protocols. The protocols provide endpoints to check server and model health, metadata and statistics. Additional endpoints allow model loading and unloading, and inferencing. See the [KFServing](https://github.com/kubeflow/kfserving/tree/master/docs/predict-api/v2) and [extension](https://github.com/NVIDIA/triton-inference-server/tree/master/docs/protocol) documentation for details.

### Uninstalling the Chart
To uninstall/delete the `example` deployment and the `example-metrics` deployment if enabled:
```bash
$ helm uninstall example # delete the inference server
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

## Values

Values for the Triton Server are described below.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nameOverride | string | `nil` | Name to override |
| fullnameOverride | string | `nil` | Full name to override |
| replicaCount | int | `1` | Number of instances to deploy for the pipeline backend deployment |
| imagePullSecrets | list | `[]` |  |
| arch | string | `amd` | Architect host server (amd/arm) |
| mode.useCpu | bool | `true` | Enable/Disable CPU inference |
| tritonEnv.registry | string | `registry.hub.docker.com/instill` | Triton Conda Environment image registry address |
| tritonEnv.repository | string | `triton-conda-env` | Triton Conda Environment image repository name |
| tritonEnv.tag | string | `0.2.6-alpha` | The image tag |
| tritonEnv.pullPolicy | string | `"IfNotPresent"` | Triton Conda Environment Image pull policy |
| image.registry | string | `registry.hub.docker.com/instill` | The image registry address |
| image.repository | string | `tritonserver` | The image repository name |
| image.tag | string | `22.05` | The image tag |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.modelRepositoryPath | string | `"/model-repository"` | Model repository path |
| image.condaPackPath | string | `"/conda-pack"` | Conda pack path |
| image.condaPackFileName | string | `"python-3-8.tar.gz"` | Conda pack file name |
| image.numGpus | int | `1` | Number of GPUs |
| service.nodePortGrpc | int | `31001` | Kubernetes service nodePort for gRPC endpoint (optional). Same remarks. |
| service.nodePortHttp | int | `31000` | Kubernetes service nodePort for HTTP/REST endpoint (optional). If the service node port is not set, the Kubernetes control plane will allocate a port from a range (default for NodePort use: 30000-32767). If it is set to a specific port, the control plane will either allocate you that port or report failure. This means you need to take care of possible port colisions. You also have to use a valid port number, one that's inside the above range. |
| service.nodePortMetrics | int | `31002` | Kubernetes service nodePort for Metrics endpoint (optional). Same remarks. |
| service.portGrpc | int | `8001` | Kubernetes internal service port for gRPC endpoint |
| service.portHttp | int | `8000` | Kubernetes internal service port for HTTP/REST endpoint |
| service.portMetrics | int | `8002` |  |
| service.type | string | `"NodePort"` | Kubernetes service type |
| nodeSelector | object | `{}` | Pod nodeSelector |
| tolerations | list | `[]` | Pod tolerations |
| affinity | object | `{}` | Pod affinity |
| podAnnotations | object | `{}` | Additional deployment annotations |
| podDisruptionBudget.enabled | bool | `false` |  |
| podDisruptionBudget.maxUnavailable | string | `nil` |  |
| podDisruptionBudget.minAvailable | int | `1` |  |