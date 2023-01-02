.DEFAULT_GOAL:=help

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
	@docker inspect --type=image ${TRITONSERVER_IMAGE_TAG} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@docker compose up -d
	@docker compose rm -f

.PHONY: dev
dev:			## Lunch all dependent services given a profile set
	@COMPOSE_PROFILES=$(PROFILE) docker compose -f docker-compose-dev.yml up -d
	@COMPOSE_PROFILES=$(PROFILE) docker compose -f docker-compose-dev.yml rm -f

.PHONY: temporal
temporal:		## Launch Temporal services
	@docker compose up -d temporal temporal_admin_tools temporal_ui

.PHONY: logs
logs:			## Tail all logs with -n 10
	@docker compose logs --follow --tail=10

.PHONY: pull
pull:			## Pull all service images
	@docker inspect --type=image ${TRITONSERVER_IMAGE_TAG} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@docker compose pull

.PHONY: stop
stop:			## Stop all components
	@docker compose stop

.PHONY: start
start:			## Start all stopped services
	@docker compose start

.PHONY: restart
restart:		## Restart all services
	@docker compose restart

.PHONY: rm
rm:				## Remove all stopped service containers
	@docker compose rm -f

.PHONY: down
down:			## Stop all services and remove all service containers and volumes
	@docker compose down -v

.PHONY: images
images:			## List all container images
	@docker compose images

.PHONY: ps
ps:				## List all service containers
	@docker compose ps

.PHONY: top
top:			## Display all running service processes
	@docker compose top

.PHONY: build
build:							## Build latest images for all VDP components
	@docker build -f Dockerfile.dev \
		--build-arg GOLANG_VERSION=${GOLANG_VERSION} \
		--build-arg UBUNTU_VERSION=${UBUNTU_VERSION} \
		-t instill/vdp:dev .
	@docker run -t --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${PWD}/.env:/vdp/dev/.env \
		-v ${PWD}/docker-compose-dev.yml:/vdp/dev/docker-compose-dev.yml \
		-e TRITONSERVER_RUNTIME=${TRITONSERVER_RUNTIME} \
		-e TRITONSERVER_IMAGE_TAG=${TRITONSERVER_IMAGE_TAG} \
		-e TRITONCONDAENV_IMAGE_TAG=${TRITONCONDAENV_IMAGE_TAG} \
		-e REDIS_IMAGE_TAG=${REDIS_IMAGE_TAG} \
		--name vdp-build \
		instill/vdp:dev /bin/bash -c " \
			git -C api-gateway fetch && git -C api-gateway reset --hard origin/main && \
			git -C pipeline-backend fetch && git -C pipeline-backend reset --hard origin/main && \
			git -C connector-backend fetch && git -C connector-backend reset --hard origin/main && \
			git -C model-backend fetch && git -C model-backend reset --hard origin/main && \
			git -C mgmt-backend fetch && git -C mgmt-backend reset --hard origin/main && \
			git -C console fetch && git -C console reset --hard origin/main && \
			COMPOSE_PROFILES=$(PROFILE) docker compose -f docker-compose-dev.yml build \
		"

.PHONY: doc
doc:						## Run Redoc for OpenAPI spec at http://localhost:3001
	@docker compose up -d redoc_openapi

.PHONY: integration-test
integration-test:			## Run integration test for all dev repositories
	@make build PROFILE=all
	@make dev PROFILE=all ITMODE=true
	@docker rm -f vdp-integration-test >/dev/null 2>&1 | true
	@docker run -d --rm --network host --name vdp-integration-test instill/vdp:dev tail -f /dev/null
	@docker exec -t vdp-integration-test /bin/bash -c "cd console && npm install && npx playwright install --with-deps && npx playwright test"
	@docker exec -t vdp-integration-test /bin/bash -c "cd pipeline-backend && make integration-test HOST=localhost"
	@docker exec -t vdp-integration-test /bin/bash -c "cd connector-backend && make integration-test HOST=localhost"
	@docker exec -t vdp-integration-test /bin/bash -c "cd model-backend && make integration-test HOST=localhost"
	@docker exec -t vdp-integration-test /bin/bash -c "cd mgmt-backend && make integration-test HOST=localhost"
	@docker stop -t 1 vdp-integration-test
	@make down

.PHONY: help
help:       	## Show this help
	@echo "\nMake Application with Docker Compose"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
