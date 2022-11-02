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

#### Pull images from a private registry
Our customized Triton server images are stored in Harbor which is a private registry, credentials need to be provided. Among [different ways](https://kubernetes.io/docs/concepts/containers/images/#using-a-private-registry), we choose specifying ImagePullSecrets on a Pod, which is the recommended approach to run containers based on images in private registries. Use [our Harbor registry](https://harbor.instill.tech) as an example:
```bash
$ kubectl create secret docker-registry [secret_name] --docker-server=[harbor_domain] --docker-username=[harbor_username] --docker-password=[harbor_cli_key]
```
where
- `secret_name` is the name of the secret you refer to on a Pod. In this case, it should be the same as `image.imagePullSecretsName` in `values.yaml`
- `habor_domain` is the Harbor domain name: `'https://harbor.instill.tech'`
- `harbor_username` is your username to login to Harbor
- `harbor_cli_key` is your Harbor CLI key

This will set your Docker credentials as a Secret in the cluster. The Pods that use the private registry get credentials from the secret to pull the images.

#### Deploy Triton inference server
There are two ways to deploy with Helm
- Install from source
- Install from a repository (e.g. our Harbor repository)

The following commands deploy the inference server in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

##### Install from source
To install the chart with the release name `example`:
```bash
$ helm dependency update  # retrieve dependent charts into charts/ directory
$ helm install example .  # deploy the server
```

##### Install from repository
To install from Harbor repository with the release name `example`:
```bash
$ helm repo add --username [harbor_username] --password [harbor_cli_key] triton https://instill-harbor.ngrok.io/chartrepo/triton  # add Harbor project as separate index entry point
$ helm repo update  # update info of available charts
$ helm install --username [harbor_username] --password [harbor_cli_key] example triton/triton-inference-server --version [chart_version]  # deploy the server
```
where
- `harbor_username` is your username to login to Harbor
- `harbor_cli_key` is your Harbor CLI key
- `chart_version` is the chart version to install. If this is not specified, the latest version is installed.

### Use the inference server
Now the inference server is running, you can send HTTP or GRPC requests to it to perform inferencing. On a _cluster-internal IP_, The inference server exposes
- an HTTP endpoint on port `8000`,
- a GRPC endpoint on port `8001`, and
- a Prometheus metrics endpoint on port `8002`

By default, the inference server is exposed with a `NodePort` service type. You'll be able to contact the service from outside the cluster by requesting `[NodeIP]:[NodePort]`. Get the ports if they are not specified in `single_server/values.yaml`
```bash
$ kubectl describe service example-triton-inference-server | grep NodePort
```
You can use curl to get the meta-data of the inference server from the HTTP endpoint:
```
$ curl [NodeIP]:[http_nodeport]/v2
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
| affinity | object | `{}` | Pod affinity |
| fullnameOverride | string | `nil` | Full name to override |
| image.condaPackFile | string | `"/conda-pack/python-3-8.tar.gz"` |  |
| image.customOpsTensorRT.directory | string | `"/custom-ops-tensorrt"` | Path to directory containing the libraries for the TensorRT custom ops. Either a local path if `modelRepositoryStorage = local` (e.g. `/raid/triton-repo-20-11/custom-ops-tensorrt`) or a gcs path if `modelRepositoryStorage = gcs` (e.g. gs://instill-europe-west2-triton-models/custom-ops-tensorrt) |
| image.customOpsTensorRT.lib | string | `"*.so"` | Library to load for the TensorRT custom ops |
| image.gcsCredentialJsonFilename | string | `"gcp-creds.json"` | Name of the credential json file contained in `gcsSecretName`. Only for `modelRepositoryStorage = gcs` |
| image.gcsSecretName | string | `"gcp-creds"` | Name of the Kubernetes Secret to authenticate to GCS. The secret contains the json file that would be set in `GOOGLE_APPLICATION_CREDENTIALS`. Only for `modelRepositoryStorage = gcs` |
| image.modelRepositoryPath | string | `"/models"` | Path to the model repository. Either a local path if `modelRepositoryStorage = local` (e.g. `/raid/triton-repo-2011/models`) or a gcs path if `modelRepositoryStorage = gcs` (e.g. gs://instill-europe-west2-triton-models) |
| image.modelRepositoryStorage | string | `"local"` | Storage for the model repository. Either `local` or `gcs` |
| image.numGpus | int | `1` | Number of GPUs on the machine to be exposed inside the container. If set to `0`, all the GPUs will be exposed. Only applicable when `mode.useCPU=false` |
| image.pullPolicy | string | `"Always"` | Image pull policy |
| image.registry | string | `nil` | The image registry address |
| image.repository | string | `nil` | The image repository name |
| image.tag | string | `nil` | The image tag |
| mode.useCpu | bool | `true` | Enable/Disable CPU inference |
| modelManagement.loadModel | string | `""` | Name of the model to be loaded for `explicit` model control mode (`modelManagement.modelControlMode=explicit`) |
| modelManagement.modelControlMode | string | `"poll"` | Model control mode for model management. Choose from `none`, `poll` or `explicit`. For "none", the server will load all models in the model repository at startup and will not make any changes to the load models after that. For "poll", the server will poll the model repository to detect changes and will load/unload models based on those changes. The poll rate is controlled by "repositoryPollSecs". For "explicit", model load and unload is initiated by using the model control APIs, and only models specified with "loadModel" will be loaded at startup. |
| modelManagement.repositoryPollSecs | int | `15` | Poll rate to detect changes in model repository for `poll` model control mode (`modelManagement.modelControlMode=poll`) |
| nameOverride | string | `nil` | Name to override |
| nodeSelector | object | `{}` | Pod nodeSelector |
| podAnnotations | object | `{}` | Additional deployment annotations |
| podDisruptionBudget.enabled | bool | `false` |  |
| podDisruptionBudget.maxUnavailable | string | `nil` |  |
| podDisruptionBudget.minAvailable | int | `1` |  |
| replicaCount | int | `1` | Number of instances to deploy for the server deployment |
| service.nodePortGrpc | int | `31001` | Kubernetes service nodePort for gRPC endpoint (optional). Same remarks. |
| service.nodePortHttp | int | `31000` | Kubernetes service nodePort for HTTP/REST endpoint (optional). If the service node port is not set, the Kubernetes control plane will allocate a port from a range (default for NodePort use: 30000-32767). If it is set to a specific port, the control plane will either allocate you that port or report failure. This means you need to take care of possible port colisions. You also have to use a valid port number, one that's inside the above range. |
| service.nodePortMetrics | int | `31002` | Kubernetes service nodePort for Metrics endpoint (optional). Same remarks. |
| service.portGrpc | int | `8001` | Kubernetes internal service port for gRPC endpoint |
| service.portHttp | int | `8000` | Kubernetes internal service port for HTTP/REST endpoint |
| service.portMetrics | int | `8002` |  |
| service.type | string | `"NodePort"` | Kubernetes service type |
| tolerations | list | `[]` | Pod tolerations |
