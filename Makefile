.DEFAULT_GOAL:=help

TEMPORAL := temporal temporal_admin_tools temporal_ui

#============================================================================

# load environment variables
include .env
export

TRITONSERVER_IMAGE_TAG := $(if $(filter arm64,$(shell uname -m)),instill/tritonserver:${TRITON_SERVER_VERSION}-py3-cpu-arm64,nvcr.io/nvidia/tritonserver:${TRITON_SERVER_VERSION}-py3)
TRITONCONDAENV_IMAGE_TAG := $(if $(filter arm64,$(shell uname -m)),instill/triton-conda-env:${TRITON_CONDA_ENV_VERSION}-m1,instill/triton-conda-env:${TRITON_CONDA_ENV_VERSION}-cpu)
REDIS_IMAGE_TAG := $(if $(filter arm64,$(shell uname -m)),arm64v8/redis:${REDIS_VERSION}-alpine,amd64/redis:${REDIS_VERSION}-alpine)

NVIDIA_SMI := $(shell nvidia-smi 2>/dev/null 1>&2; echo $$?)
ifeq ($(NVIDIA_SMI),0)
	TRITONSERVER_RUNTIME := nvidia
	TRITONCONDAENV_IMAGE_TAG := instill/triton-conda-env:${TRITON_CONDA_ENV_VERSION}-gpu
endif

#============================================================================

.PHONY: all
all:			## Launch all services with their up-to-date release version
	@docker inspect --type=image ${TRITONSERVER_IMAGE_TAG} >/dev/null 2>&1 || printf "\033[1;33mWARNING:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@docker-compose up -d

.PHONY: dev
dev:			## Lunch all dependent services given the profile
	COMPOSE_PROFILES=$(PROFILE) docker-compose -f docker-compose-dev.yml up -d

.PHONY: temporal
temporal:		## Launch Temporal services
	@docker-compose up -d ${TEMPORAL}

.PHONY: logs
logs:			## Tail all logs with -n 10
	@docker-compose logs --follow --tail=10

.PHONY: pull
pull:			## Pull all service images
	@docker inspect --type=image ${TRITONSERVER_IMAGE_TAG} >/dev/null 2>&1 || printf "\033[1;33mWARNING:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@docker-compose pull

.PHONY: stop
stop:			## Stop all components
	@docker-compose stop

.PHONY: start
start:			## Start all stopped services
	@docker-compose start

.PHONY: restart
restart:		## Restart all services
	@docker-compose restart

.PHONY: rm
rm:				## Remove all stopped service containers
	@docker-compose rm -f

.PHONY: down
down:			## Stop all services and remove all service containers and volumes
	@docker-compose down -v

.PHONY: images
images:			## List all container images
	@docker-compose images

.PHONY: ps
ps:				## List all service containers
	@docker-compose ps

.PHONY: top
top:			## Display all running service processes
	@docker-compose top

.PHONY: build
build:							## Build all dev docker images
	@printf "set up latest pipeline-backend: " && [ ! -d "dev/pipeline-backend" ] && git clone https://github.com/instill-ai/pipeline-backend.git dev/pipeline-backend || git -C dev/pipeline-backend fetch && git -C dev/pipeline-backend reset --hard origin/main
	@printf "set up latest connector-backend: " && [ ! -d "dev/connector-backend" ] && git clone https://github.com/instill-ai/connector-backend.git dev/connector-backend || git -C dev/connector-backend fetch && git -C dev/connector-backend reset --hard origin/main
	@printf "set up latest model-backend: " && [ ! -d "dev/model-backend" ] && git clone https://github.com/instill-ai/model-backend.git dev/model-backend || git -C dev/model-backend fetch && git -C dev/model-backend reset --hard origin/main
	@printf "set up latest mgmt-backend: " && [ ! -d "dev/mgmt-backend" ] && git clone https://github.com/instill-ai/mgmt-backend.git dev/mgmt-backend || git -C dev/mgmt-backend fetch && git -C dev/mgmt-backend reset --hard origin/main
	@printf "set up latest console: " && [ ! -d "dev/console" ] && git clone https://github.com/instill-ai/console.git dev/console || git -C dev/console fetch && git -C dev/console reset --hard origin/main
	@COMPOSE_PROFILES=$(PROFILE) docker-compose -f docker-compose-dev.yml build

.PHONY: doc
doc:						## Run Redoc for OpenAPI spec at http://localhost:3001
	@docker-compose up -d redoc_openapi

.PHONY: integration-test
integration-test:			## Run integration test for all dev repositories
	@make build PROFILE=all
	@make dev PROFILE=all
	@cd dev/pipeline-backend && HOSTNAME=localhost make integration-test
	@cd dev/connector-backend && HOSTNAME=localhost make integration-test
	@cd dev/model-backend && HOSTNAME=localhost make integration-test
	@cd dev/mgmt-backend && HOSTNAME=localhost make integration-test
	@make down

.PHONY: help
help:       	## Show this help
	@echo "\nMake Application wiht Docker Compose"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
