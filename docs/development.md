# Local development

VDP is designed with a microservice based architecture. This

On the local machine, clone `vdp` repository in your workspace, move to the repository folder, and launch all dependent microservices:
```
$ cd <your-workspace>
$ git clone https://github.com/instill-ai/vdp.git
$ cd vdp
$ make dev PROFILE=connector
```

Clone `connector-backend` repository in your workspace and move to the repository folder:
```
$ cd <your-workspace>
$ git clone https://github.com/instill-ai/connector-backend.git
$ cd connector-backend
```

### Build the dev image

```bash
$ make build
```

### Run the dev container

```bash
$ make dev
```

Now, you have the Go project set up in the container, in which you can compile and run the binaries together with the integration test in each container shell.

### Run the server

```bash
$ docker exec -it connector-backend /bin/bash
$ go run ./cmd/migration
$ go run ./cmd/init
$ go run ./cmd/main
```

### Run the Temporal worker

```bash
$ docker exec -it connector-backend /bin/bash
$ go run ./cmd/worker
```

### Run the integration test

``` bash
$ docker exec -it connector-backend /bin/bash
$ make integration-test
```

### Stop the dev container

```bash
$ make stop
```
