.DEFAULT_GOAL:=help

SHELL := /bin/bash

#============================================================================

# load environment variables
include .env
export

# NVIDIA_GPU_AVAILABLE:
# 	The env variable NVIDIA_GPU_AVAILABLE is set to true if NVIDIA GPU is available. Otherwise, it will be set to false.
# NVIDIA_VISIBLE_DEVICES:
# 	By default, the env variable NVIDIA_VISIBLE_DEVICES is set to all if NVIDIA GPU is available. Otherwise, it is unset.
#	Specify the env variable NVIDIA_VISIBLE_DEVICES to override the default value.
NVIDIA_VISIBLE_DEVICES := ${NVIDIA_VISIBLE_DEVICES}
ifeq ($(shell nvidia-smi 2>/dev/null 1>&2; echo $$?),0)
	NVIDIA_GPU_AVAILABLE := true
	ifndef NVIDIA_VISIBLE_DEVICES
		NVIDIA_VISIBLE_DEVICES := all
	endif
	RAY_RELEASE_TAG := ${RAY_VERSION}-gpu
else
	NVIDIA_GPU_AVAILABLE := false
	RAY_RELEASE_TAG := ${RAY_VERSION}
endif

COMPOSE_FILES := -f docker-compose.yml
ifeq (${OBSERVE_ENABLED}, true)
	COMPOSE_FILES := ${COMPOSE_FILES} -f docker-compose-observe.yml
endif

UNAME_S := $(shell uname -s)

INSTILL_CORE_IMAGE_NAME := instill/instill-core

CONTAINER_COMPOSE_INTEGRATION_TEST_NAME := instill-core-compose-integration-test

HELM_NAMESPACE := instill-ai
HELM_RELEASE_NAME := core

# By default, these files are used to load the secrets (OAuth, API keys, etc.)
ENV_SECRETS_COMPONENT := .env.secrets.component
ENV_SECRETS_COMPONENT_TEST := .env.secrets.component.test
ENV_SECRETS_CONSOLE := .env.secrets.console

# Configuration directory path
CONFIG_DIR_PATH := ./configs/compose

GIT_COMMIT_SHA := $(shell git rev-parse --short=7 HEAD 2>/dev/null)

# 3rd-party Kubernetes namespaces
MINIO_KUBERNETES_NAMESPACE := minio

#============================================================================

include Makefile.helper

.PHONY: run
run: compose-run	## Alias for compose-run: Launch all services by docker compose


.PHONY: compose-run
compose-run:	## Launch all services by docker compose
	$(call ENSURE_USER_UID)
ifeq (${NVIDIA_GPU_AVAILABLE}, true)
	$(call COMPOSE_GPU,$(call GET_COMPOSE_PARAMS),${COMPOSE_FILES})
else
	$(call COMPOSE_CPU,$(call GET_COMPOSE_PARAMS),${COMPOSE_FILES})
endif

.PHONY: compose-dev
compose-dev:	## Lunch all services with docker compose dev profile
	$(call ENSURE_USER_UID)
ifeq (${NVIDIA_GPU_AVAILABLE}, true)
	$(call COMPOSE_GPU,$(call GET_COMPOSE_PARAMS),${COMPOSE_FILES} -f docker-compose-dev.yml)
else
	$(call COMPOSE_CPU,$(call GET_COMPOSE_PARAMS),${COMPOSE_FILES} -f docker-compose-dev.yml)
endif

.PHONY: helm-run
helm-run:		## Launch all services by helm
	$(call HELM,$(CI))

.PHONY: down
down:			## Stop all services and remove all service containers and volumes
	@if EDITION= DEFAULT_USER_UID= docker compose ps --services | grep -q .; then \
		EDITION= DEFAULT_USER_UID= docker compose down --remove-orphans -v; \
	fi
	$(call REMOVE_CONTAINERS)
	$(call REMOVE_HELM_RESOURCES)

.PHONY: logs
logs:			## Tail all logs with -n 10
	@EDITION= DEFAULT_USER_UID= docker compose logs --follow --tail=10

.PHONY: pull
pull:			## Pull all service images
	@docker inspect --type=image instill/ray:${RAY_VERSION} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Ray image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@EDITION= DEFAULT_USER_UID= docker compose pull

.PHONY: stop
stop:			## Stop all components
	@EDITION= DEFAULT_USER_UID= docker compose stop

.PHONY: start
start:			## Start all stopped components
	@EDITION= DEFAULT_USER_UID= docker compose start

.PHONY: images
images:			## List all container images
	@docker compose images

.PHONY: ps
ps:				## List all service containers
	@EDITION= DEFAULT_USER_UID= docker compose ps

.PHONY: top
top:			## Display all running service processes
	@EDITION= DEFAULT_USER_UID= docker compose top

.PHONY: integration-test
integration-test:                   ## Run all integration tests (compose, helm, and model)
	$(call BUILD_DEV)
	$(call MODEL_INTEGRATION_TEST)
	$(call COMPOSE_INTEGRATION_TEST)
	$(call HELM_INTEGRATION_TEST)


.PHONY: model-integration-test
model-integration-test:       	 	# Run integration test on the Instill Core to build, push and deploy dummy models
	$(call BUILD_DEV)
	$(call MODEL_INTEGRATION_TEST)

.PHONY: compose-integration-test
compose-integration-test:			# Run integration test on the Instill Core Docker Compose
	$(call BUILD_DEV)
	$(call COMPOSE_INTEGRATION_TEST)

.PHONY: helm-integration-test
helm-integration-test:              # Run integration test on the Instill Core Helm
	$(call BUILD_DEV)
	$(call HELM_INTEGRATION_TEST)

.PHONY: build-and-push-models
build-and-push-models:	# Helper target to build and push models
	@./integration-test/scripts/build-and-push-models.sh "$(PWD)/integration-test/models" "localhost:${REGISTRY_HOST_PORT}"

.PHONY: wait-models-deploy
wait-models-deploy:  # Helper target to wait for model deployment
	@model_count=$$(jq length integration-test/models/inventory.json); \
	timeout=1800; elapsed=0; spinner='|/-\\'; i=0; \
	while [ "$$(docker run --rm --network instill-network curlimages/curl:latest curl -s http://${RAY_HOST}:${RAY_PORT_DASHBOARD}/api/serve/applications/ | jq ".applications | to_entries | map(select(.key | contains(\"dummy-\")) | .value.status) | length == $$model_count and all(. == \"RUNNING\")")" != "true" ]; do \
		running_count=$$(docker run --rm --network instill-network curlimages/curl:latest curl -s http://${RAY_HOST}:${RAY_PORT_DASHBOARD}/api/serve/applications/ | jq '.applications | to_entries | map(select(.key | contains("dummy-")) | .value.status) | map(select(. == "RUNNING")) | length'); \
		printf "\r[Waiting %3ds/%ds] %s models still deploying... (%d/%d RUNNING)" "$$elapsed" "$$timeout" "$${spinner:$$((i % 4)):1}" "$$running_count" "$$model_count"; \
		sleep 1; elapsed=$$((elapsed+1)); \
		if [ "$$elapsed" -ge "$$timeout" ]; then \
			echo "\nTimeout waiting for models to deploy!"; exit 1; \
		fi; \
		i=$$((i + 1)); \
	done; \
	printf "\nAll %d models deployed and running.\n" "$$model_count"

.PHONY: help
help:       	## Show this help
	@printf "\nMake Application with Instill Core\n"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
