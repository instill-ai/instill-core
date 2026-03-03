# AGENTS.md

This file provides context and instructions for AI coding agents working on the Instill Core repository.

## Project overview

**Instill Core** is an end-to-end AI platform for data, pipeline, and model orchestration. It uses a microservice architecture with Docker Compose for local development. Each service runs as a container, and development involves modifying, containerizing, and deploying the updated codebase.

## Setup commands

```shell
# Launch all services (production mode)
make run

# Launch all services with development profile
make compose-dev

# Stop all services and remove containers/volumes
make down

# Pull all service images
make pull
```

## Service ports

| Service            | Port | Description                      |
| ------------------ | ---- | -------------------------------- |
| `api-gateway`      | 8080 | API request/response handling    |
| `pipeline-backend` | 8081 | Pipeline building and management |
| `artifact-backend` | 8082 | RAG-related resources            |
| `model-backend`    | 8083 | AI model import and serving      |
| `mgmt-backend`     | 8084 | User account management          |
| `console`          | 3000 | Web UI                           |

## Development environment tips

- Use `make ps` to list all running service containers
- Use `make logs` to tail all logs (follows with -n 10)
- Use `make stop` and `make start` to pause/resume services without removing them
- Use `make top` to display running processes in each container
- Environment variables are loaded from `.env` - customize as needed
- All backend configuration variables are prefixed with `CFG_`
- Component secrets (OAuth, API keys) go in `.env.secrets.component`
- Console OAuth secrets go in `.env.secrets.console`

## Developing on a specific service

To work on a backend service (e.g., `pipeline-backend`):

```shell
# 1. Remove the running containers
docker rm pipeline-backend pipeline-backend-worker

# 2. Clone and enter the service repo
git clone https://github.com/instill-ai/pipeline-backend.git
cd pipeline-backend

# 3. Build and run the dev image
make compose-dev

# 4. In the container, run the service
docker exec -it pipeline-backend bash
go run ./cmd/migration
go run ./cmd/init
go run ./cmd/main

# 5. In another terminal, start the Temporal worker
docker exec -it pipeline-backend bash
go run ./cmd/worker
```

## Testing instructions

```shell
# Run all integration tests (compose, helm, and model)
make integration-test

# Run specific test suites
make compose-integration-test   # Docker Compose integration tests
make helm-integration-test      # Helm integration tests
make model-integration-test     # Model build/push/deploy tests

# Run service-specific integration tests (inside container)
docker exec -it pipeline-backend bash
make integration-test API_GATEWAY_URL=api-gateway:8080 DB_HOST=pg-sql
```

- Always run integration tests before submitting a PR
- First open a `draft` PR to trigger CI workflows
- Mark PR as `open` only after all tests pass

## Code style

- Backend services are written in Go
- Use [Koanf](https://github.com/knadh/koanf) for configuration management
- Configuration environment variables are prefixed with `CFG_`
- Follow standard Go formatting and linting practices
- Pre-commit hooks are configured in `.pre-commit-config.yaml`

## Architecture

```text
instill-core/
├── .env                     # Environment variables
├── .env.secrets.component   # Component secrets (API keys, OAuth)
├── .env.secrets.console     # Console OAuth secrets
├── docker-compose.yml       # Main compose file
├── docker-compose-dev.yml   # Development profile
├── docker-compose-nvidia.yml # NVIDIA GPU support
├── docker-compose-observe.yml # Observability stack
├── Makefile                 # Build and orchestration commands
├── charts/                  # Helm charts for Kubernetes deployment
├── configs/                 # Service configurations
│   ├── compose/             # Docker Compose configs
│   └── helm/                # Helm chart configs
└── integration-test/        # Integration test resources
    ├── models/              # Dummy models for testing
    └── scripts/             # Test helper scripts
```

## PR instructions

- Follow [conventional commits](https://www.conventionalcommits.org/) for commit messages
- Branch naming: `<your-github-username>/<what-your-pr-about>`
- Always run `make integration-test` locally before pushing
- Open a `draft` PR first to run CI integration tests
- Mark PR as `open` only after tests pass
- See [CONTRIBUTING.md](./.github/CONTRIBUTING.md) for detailed guidelines

## Helm deployment

```shell
# Deploy via Helm
make helm-run

# Helm resources are cleaned up with
make down
```

## GPU support

If NVIDIA GPU is available, the system auto-detects it and uses GPU-enabled configurations. Override with:

```shell
export NVIDIA_VISIBLE_DEVICES=all  # or specific device IDs
```

## Observability

Enable observability stack (Grafana, Prometheus, Loki, Tempo):

```shell
# In .env, set:
OBSERVE_ENABLED=true

# Then launch
make run
```

Grafana dashboards are in `configs/compose/grafana/dashboards/`.
