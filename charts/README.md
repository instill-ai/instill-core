## Quick start

Execute the following commands to deploy backend services into minikube cluster:

```bash
# Download minikube, helm
$ make setup
$ make start
# init db, redis, namespace and secret
$ make init
# install helm charts
$ make install
```

Execute the following commands to destroy services:

```bash
# delete all namespace and resources inside
$ make delete
```