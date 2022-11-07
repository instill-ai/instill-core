## Quick start

Execute the following commands to deploy backend services into minikube cluster:

```bash
# Download minikube, helm
$ make setup
```

Go to other terminal and run make start (start minikube tunnel)
```bash
$ make start
```

```bash
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