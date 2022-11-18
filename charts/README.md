## Quick start

### Execute the following commands to deploy backend services into local Kubernetes cluster:

#### Download tools minikube/kind/temporal
```bash
# Download minikube/kind, helm
# kube=minikube or kube=kind is optional parameter, default is minikube 
$ make setup # deploy with Minikube
OR
$ make setup kube=minikube
OR
$ make setup kube=kind  # deploy with Kind
```

#### Start creating a local Kubernetes cluster
```bash
# start creating Kubernetes cluster
# kube=minikube or kube=kind is optional parameter, default is minikube 
$ make start
OR
$ make start kube=minikube
OR
$ make start kube=kind  # deploy with Kind
```

#### Deploy db, redis, namespace and secret and Instill services 
```bash
# init db, redis, namespace and secret
$ make init
# install Instill service helm charts
$ make install
```

#### Undeploy service
```bash
# uninstall Instill service helm charts
$ make uninstall
# destroy all namespace for db, redis and Instill services
$ make destroy
```

#### Execute the following commands to destroy services:
```bash
# delete all namespace and resources inside
# kube=minikube or kube=kind is optional parameter, default is minikube 
$ make delete
OR
$ make delete kube=minikube
OR
$ make delete kube=kind
```