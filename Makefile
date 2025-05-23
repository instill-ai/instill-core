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
	RAY_LATEST_TAG := latest-gpu
	RAY_RELEASE_TAG := ${RAY_VERSION}-gpu
else
	NVIDIA_GPU_AVAILABLE := false
	RAY_LATEST_TAG := latest
	RAY_RELEASE_TAG := ${RAY_VERSION}
endif

COMPOSE_FILES := -f docker-compose.yml
ifeq (${OBSERVE_ENABLED}, true)
	COMPOSE_FILES := ${COMPOSE_FILES} -f docker-compose-observe.yml
endif

UNAME_S := $(shell uname -s)

INSTILL_CORE_IMAGE_NAME := instill/instill-core
INSTILL_CORE_VERSION := $(shell git tag --sort=committerdate | grep -E '[0-9]' | tail -1 | cut -b 2-)

CONTAINER_BUILD_NAME := instill-core-build
CONTAINER_BACKEND_INTEGRATION_TEST_NAME := instill-core-backend-integration-test

# TODO: Remove these
INSTILL_CORE_CONSOLE_INTEGRATION_TEST_CONTAINER_NAME := instill-core-console-integration-test
INSTILL_CORE_CONSOLE_PLAYWRIGHT_IMAGE_NAME := instill/console-playwright

HELM_NAMESPACE := instill-ai
HELM_RELEASE_NAME := core

# By default, these files are used to load the secrets (OAuth, API keys, etc.)
ENV_SECRETS_COMPONENT := .env.secrets.component
ENV_SECRETS_COMPONENT_TEST := .env.secrets.component.test
ENV_SECRETS_CONSOLE := .env.secrets.console

# Configuration directory path
CONFIG_DIR_PATH ?= ./configs

#============================================================================

.PHONY: all
all:			## Launch all services with their up-to-date release version
	@docker inspect --type=image instill/ray:${RAY_RELEASE_TAG} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Ray image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@if [ ! -f "$$(echo ${SYSTEM_CONFIG_PATH}/user_uid)" ]; then \
		mkdir -p ${SYSTEM_CONFIG_PATH} && \
		uuidgen > ${SYSTEM_CONFIG_PATH}/user_uid; \
	fi
ifeq (${NVIDIA_GPU_AVAILABLE}, true)
	@cat docker-compose-nvidia.yml | yq '.services.ray.deploy.resources.reservations.devices[0].device_ids |= (strenv(NVIDIA_VISIBLE_DEVICES) | split(",")) | ..style="double"' | \
		EDITION=$${EDITION:=local-ce} DEFAULT_USER_UID=$$(cat ${SYSTEM_CONFIG_PATH}/user_uid) RAY_RELEASE_TAG=${RAY_RELEASE_TAG} ENV_SECRETS_COMPONENT=${ENV_SECRETS_COMPONENT} \
		docker compose ${COMPOSE_FILES} -f - up -d --quiet-pull
else
	@EDITION=$${EDITION:=local-ce} DEFAULT_USER_UID=$$(cat ${SYSTEM_CONFIG_PATH}/user_uid) RAY_RELEASE_TAG=${RAY_RELEASE_TAG} ENV_SECRETS_COMPONENT=${ENV_SECRETS_COMPONENT} \
		docker compose ${COMPOSE_FILES} up -d --quiet-pull
endif

.PHONY: latest
latest:			## Lunch all dependent services with their latest codebase
	@docker inspect --type=image instill/ray:${RAY_LATEST_TAG} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Ray image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@if [ ! -f "$$(echo ${SYSTEM_CONFIG_PATH}/user_uid)" ]; then \
		mkdir -p ${SYSTEM_CONFIG_PATH} && \
		uuidgen > ${SYSTEM_CONFIG_PATH}/user_uid; \
	fi
ifeq (${NVIDIA_GPU_AVAILABLE}, true)
	@cat docker-compose-nvidia.yml | yq '.services.ray.deploy.resources.reservations.devices[0].device_ids |= (strenv(NVIDIA_VISIBLE_DEVICES) | split(",")) | ..style="double"' | \
		COMPOSE_PROFILES=${PROFILE} EDITION=$${EDITION:=local-ce:latest} DEFAULT_USER_UID=$$(cat ${SYSTEM_CONFIG_PATH}/user_uid) RAY_LATEST_TAG=${RAY_LATEST_TAG} ENV_SECRETS_COMPONENT=${ENV_SECRETS_COMPONENT} \
		docker compose ${COMPOSE_FILES} -f docker-compose-latest.yml -f - up -d --quiet-pull
else
	@COMPOSE_PROFILES=${PROFILE} EDITION=$${EDITION:=local-ce:latest} DEFAULT_USER_UID=$$(cat ${SYSTEM_CONFIG_PATH}/user_uid) RAY_LATEST_TAG=${RAY_LATEST_TAG} ENV_SECRETS_COMPONENT=${ENV_SECRETS_COMPONENT} \
		docker compose ${COMPOSE_FILES} -f docker-compose-latest.yml up -d --quiet-pull
endif

.PHONY: helm-latest
helm-latest:
	@helm install ${HELM_RELEASE_NAME} charts/core \
		--namespace ${HELM_NAMESPACE} --create-namespace \
		--set edition=k8s-ce:test \
		--set apiGateway.image.tag=latest \
		--set mgmtBackend.image.tag=latest \
		--set mgmtBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set artifactBackend.image.tag=latest \
		--set pipelineBackend.image.tag=latest \
		--set pipelineBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set modelBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set modelBackend.image.tag=latest \
		--set console.image.tag=latest \
		--set ray-cluster.image.tag=${RAY_LATEST_TAG} \
		--timeout 3600s
	@kubectl rollout status deployment ${HELM_RELEASE_NAME}-api-gateway --namespace ${HELM_NAMESPACE} --timeout=600s
	@kubectl --namespace ${HELM_NAMESPACE} port-forward $$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=api-gateway" -o jsonpath="{.items[0].metadata.name}") ${API_GATEWAY_PORT}:${API_GATEWAY_PORT} > /dev/null 2>&1 &
	@kubectl --namespace ${HELM_NAMESPACE} port-forward $$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=console" -o jsonpath="{.items[0].metadata.name}") ${CONSOLE_PORT}:${CONSOLE_PORT} > /dev/null 2>&1 &
	@kubectl --namespace ${HELM_NAMESPACE} port-forward $$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "ray.io/identifier=${HELM_RELEASE_NAME}-kuberay-head" -o jsonpath="{.items[0].metadata.name}") ${RAY_PORT_DASHBOARD}:${RAY_PORT_DASHBOARD} > /dev/null 2>&1 &
	@kubectl --namespace ${HELM_NAMESPACE} port-forward $$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/name=${HELM_RELEASE_NAME}-kube-prometheus-stack-grafana" -o jsonpath="{.items[0].metadata.name}") ${GRAFANA_HOST_PORT}:${GRAFANA_PORT} > /dev/null 2>&1 &

.PHONY: helm-release
helm-release:
	@helm install ${HELM_RELEASE_NAME} charts/core \
		--namespace ${HELM_NAMESPACE} --create-namespace \
		--set edition=k8s-ce:test \
		--set apiGateway.image.tag=${API_GATEWAY_VERSION} \
		--set mgmtBackend.image.tag=${MGMT_BACKEND_VERSION} \
		--set mgmtBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set artifactBackend.image.tag=${ARTIFACT_BACKEND_VERSION} \
		--set pipelineBackend.image.tag=${PIPELINE_BACKEND_VERSION} \
		--set pipelineBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set modelBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set modelBackend.image.tag=${MODEL_BACKEND_VERSION} \
		--set console.image.tag=${CONSOLE_VERSION} \
		--set ray-cluster.image.tag=${RAY_RELEASE_TAG} \
		--timeout 3600s
	@kubectl rollout status deployment ${HELM_RELEASE_NAME}-api-gateway --namespace ${HELM_NAMESPACE} --timeout=600s
	@kubectl --namespace ${HELM_NAMESPACE} port-forward $$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=api-gateway" -o jsonpath="{.items[0].metadata.name}") ${API_GATEWAY_PORT}:${API_GATEWAY_PORT} > /dev/null 2>&1 &
	@kubectl --namespace ${HELM_NAMESPACE} port-forward $$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=console" -o jsonpath="{.items[0].metadata.name}") ${CONSOLE_PORT}:${CONSOLE_PORT} > /dev/null 2>&1 &
	@kubectl --namespace ${HELM_NAMESPACE} port-forward $$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "ray.io/identifier=${HELM_RELEASE_NAME}-kuberay-head" -o jsonpath="{.items[0].metadata.name}") ${RAY_PORT_DASHBOARD}:${RAY_PORT_DASHBOARD} > /dev/null 2>&1 &
	@kubectl --namespace ${HELM_NAMESPACE} port-forward $$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/name=${HELM_RELEASE_NAME}-kube-prometheus-stack-grafana" -o jsonpath="{.items[0].metadata.name}") ${GRAFANA_HOST_PORT}:${GRAFANA_PORT} > /dev/null 2>&1 &


.PHONY: build-latest
build-latest:				## Build latest image. Set BUILD_ALL_FROM_SOURCE=true to build all service images from source.
	@bash -c ' \
		set -e; \
		trap "$(MAKE) down" ERR INT TERM && \
		docker build --progress plain \
			--build-arg ALPINE_VERSION=${ALPINE_VERSION} \
			--build-arg K6_VERSION=${K6_VERSION} \
			--build-arg XK6_VERSION=${XK6_VERSION} \
			--build-arg XK6_SQL_VERSION=${XK6_SQL_VERSION} \
			--build-arg XK6_SQL_POSTGRES_VERSION=${XK6_SQL_POSTGRES_VERSION} \
			--build-arg CACHE_DATE="$(shell date +%Y%m%d%H%M%S)" \
			--target latest \
			-t ${INSTILL_CORE_IMAGE_NAME}:latest . && \
		if [ "$(BUILD_ALL_FROM_SOURCE)" = "true" ]; then \
			docker run --rm \
				-v /var/run/docker.sock:/var/run/docker.sock \
				-v ./.env:/instill-core/.env \
				-v ./docker-compose-build.yml:/instill-core/docker-compose-build.yml \
				--name ${CONTAINER_BUILD_NAME}-latest \
				${INSTILL_CORE_IMAGE_NAME}:latest /bin/sh -c " \
					API_GATEWAY_VERSION=latest \
					MGMT_BACKEND_VERSION=latest \
					PIPELINE_BACKEND_VERSION=latest \
					MODEL_BACKEND_VERSION=latest \
					ARTIFACT_BACKEND_VERSION=latest \
					CONSOLE_VERSION=latest \
					ENV_SECRETS_COMPONENT=${ENV_SECRETS_COMPONENT} \
					COMPOSE_PROFILES=${PROFILE} docker compose -f docker-compose-build.yml --progress plain build \
				"; \
		fi \
	'

.PHONY: build-release
build-release:				## Build release image. Set BUILD_ALL_FROM_SOURCE=true to build all service images from source.
	@bash -c ' \
		set -e; \
		trap "$(MAKE) down" ERR INT TERM && \
		docker build --progress plain \
			--build-arg ALPINE_VERSION=${ALPINE_VERSION} \
			--build-arg K6_VERSION=${K6_VERSION} \
			--build-arg XK6_VERSION=${XK6_VERSION} \
			--build-arg XK6_SQL_VERSION=${XK6_SQL_VERSION} \
			--build-arg XK6_SQL_POSTGRES_VERSION=${XK6_SQL_POSTGRES_VERSION} \
			--build-arg CACHE_DATE="$(shell date)" \
			--build-arg API_GATEWAY_VERSION=${API_GATEWAY_VERSION} \
			--build-arg MGMT_BACKEND_VERSION=${MGMT_BACKEND_VERSION} \
			--build-arg PIPELINE_BACKEND_VERSION=${PIPELINE_BACKEND_VERSION} \
			--build-arg MODEL_BACKEND_VERSION=${MODEL_BACKEND_VERSION} \
			--build-arg ARTIFACT_BACKEND_VERSION=${ARTIFACT_BACKEND_VERSION} \
			--build-arg CONSOLE_VERSION=${CONSOLE_VERSION} \
			--target release \
			-t ${INSTILL_CORE_IMAGE_NAME}:${INSTILL_CORE_VERSION} . && \
		if [ "$(BUILD_ALL_FROM_SOURCE)" = "true" ]; then \
			docker run --rm \
				-v /var/run/docker.sock:/var/run/docker.sock \
				-v ./.env:/instill-core/.env \
				-v ./docker-compose-build.yml:/instill-core/docker-compose-build.yml \
				--name ${CONTAINER_BUILD_NAME}-release \
				${INSTILL_CORE_IMAGE_NAME}:${INSTILL_CORE_VERSION} /bin/sh -c " \
					API_GATEWAY_VERSION=${API_GATEWAY_VERSION} \
					MGMT_BACKEND_VERSION=${MGMT_BACKEND_VERSION} \
					PIPELINE_BACKEND_VERSION=${PIPELINE_BACKEND_VERSION} \
					MODEL_BACKEND_VERSION=${MODEL_BACKEND_VERSION} \
					ARTIFACT_BACKEND_VERSION=${ARTIFACT_BACKEND_VERSION} \
					CONSOLE_VERSION=${CONSOLE_VERSION} \
					ENV_SECRETS_COMPONENT=${ENV_SECRETS_COMPONENT} \
					COMPOSE_PROFILES=${PROFILE} docker compose -f docker-compose-build.yml --progress plain build \
				"; \
		fi \
	'

.PHONY: down
down:			## Stop all services and remove all service containers and volumes
	@docker rm -f ${CONTAINER_BUILD_NAME}-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BUILD_NAME}-release >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release >/dev/null 2>&1
	@if EDITION= DEFAULT_USER_UID= docker compose ps --services | grep -q .; then \
		EDITION= DEFAULT_USER_UID= docker compose down --remove-orphans -v; \
	fi
	@if helm list --namespace instill-ai | grep -q "core" >/dev/null 2>&1; then \
		echo "Uninstalling Helm release core --namespace instill-ai" && \
		helm uninstall core --namespace instill-ai >/dev/null 2>&1; \
		echo "Deleting namespace instill-ai" && \
		kubectl delete namespace instill-ai >/dev/null 2>&1; \
		echo "Killing port-forward processes" && \
		pkill -f "port-forward" >/dev/null 2>&1; \
	fi

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

.PHONY: integration-test-model-deploy-latest
integration-test-model-deploy-latest:       	 	# Run integration test on the latest Instill Core to build, push and deploy dummy models
	@make latest EDITION=local-ce:test
	@make build-and-push-models
	@make latest EDITION=local-ce:test INITMODEL_ENABLED=true INITMODEL_PATH=${PWD}/integration-test/models/inventory.json
	@make wait-models-deploy
	@make down

.PHONY: integration-test-model-deploy-release
integration-test-model-deploy-release:       	 	# Run integration test on the released Instill Core to build, push and deploy dummy models
	@make all EDITION=local-ce:test
	@make build-and-push-models
	@make all EDITION=local-ce:test INITMODEL_ENABLED=true INITMODEL_PATH=${PWD}/integration-test/models/inventory.json
	@make wait-models-deploy
	@make down

.PHONY: integration-test-latest
integration-test-latest:			# Run integration test on the latest Instill Core
	@make latest EDITION=local-ce:test ENV_SECRETS_COMPONENT=${ENV_SECRETS_COMPONENT_TEST}
	@docker run --rm \
		--network ${COMPOSE_NETWORK_NAME} \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${INSTILL_CORE_IMAGE_NAME}:latest /bin/sh -c " \
			/bin/sh -c 'cd mgmt-backend && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd pipeline-backend && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT} DB_HOST=pg-sql' && \
			/bin/sh -c 'cd model-backend && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT}' \
		"
	@make down

.PHONY: integration-test-release
integration-test-release:			# Run integration test on the released Instill Core
	@make all EDITION=local-ce:test ENV_SECRETS_COMPONENT=${ENV_SECRETS_COMPONENT_TEST}
	@docker run --rm \
		--network ${COMPOSE_NETWORK_NAME} \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release \
		${INSTILL_CORE_IMAGE_NAME}:${INSTILL_CORE_VERSION} /bin/sh -c " \
			/bin/sh -c 'cd mgmt-backend && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd pipeline-backend && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT} DB_HOST=pg-sql' && \
			/bin/sh -c 'cd model-backend && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT}' \
		"
	@make down

.PHONY: helm-integration-test-latest
helm-integration-test-latest:                       # Run integration test on the Helm latest for Instill Core
	@$(MAKE) helm-latest
	@while ! nc -vz localhost ${API_GATEWAY_PORT} > /dev/null 2>&1; do sleep 1; done
ifeq ($(UNAME_S),Darwin)
	@docker run --rm --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest ${INSTILL_CORE_IMAGE_NAME}:latest /bin/sh -c " \
			/bin/sh -c 'cd mgmt-backend && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd pipeline-backend && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT} DB_HOST=host.docker.internal' && \
			/bin/sh -c 'cd model-backend && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' \
		"
else ifeq ($(UNAME_S),Linux)
	@docker run --rm --network host --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest ${INSTILL_CORE_IMAGE_NAME}:latest /bin/sh -c " \
			/bin/sh -c 'cd mgmt-backend && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd pipeline-backend && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd model-backend && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' \
		"
endif
	@helm uninstall ${HELM_RELEASE_NAME} --namespace ${HELM_NAMESPACE}
	@kubectl delete namespace instill-ai
	@pkill -f "port-forward"
	@make down

.PHONY: helm-integration-test-release
helm-integration-test-release:                       # Run integration test on the Helm release for Instill Core
	@$(MAKE) helm-release
	@while ! nc -vz localhost ${API_GATEWAY_PORT} > /dev/null 2>&1; do sleep 1; done
ifeq ($(UNAME_S),Darwin)
	@docker run --rm --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release ${INSTILL_CORE_IMAGE_NAME}:${INSTILL_CORE_VERSION} /bin/sh -c " \
			/bin/sh -c 'cd mgmt-backend && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd pipeline-backend && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT} DB_HOST=host.docker.internal' && \
			/bin/sh -c 'cd model-backend && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' \
		"
else ifeq ($(UNAME_S),Linux)
	@docker run --rm --network host --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release ${INSTILL_CORE_IMAGE_NAME}:${INSTILL_CORE_VERSION} /bin/sh -c " \
			/bin/sh -c 'cd mgmt-backend && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd pipeline-backend && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd model-backend && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' \
		"
endif
	@helm uninstall ${HELM_RELEASE_NAME} --namespace ${HELM_NAMESPACE}
	@kubectl delete namespace instill-ai
	@pkill -f "port-forward"
	@make down

.PHONY: console-integration-test-latest
console-integration-test-latest:			# Run console integration test on the latest Instill Core
	@make latest EDITION=local-ce:test INSTILL_CORE_HOST=${API_GATEWAY_HOST} ENV_SECRETS_COMPONENT=${ENV_SECRETS_COMPONENT_TEST}
	@docker run --rm \
		-e NEXT_PUBLIC_GENERAL_API_VERSION=v1beta \
		-e NEXT_PUBLIC_MODEL_API_VERSION=v1alpha \
		-e NEXT_PUBLIC_CONSOLE_EDITION=local-ce:test \
		-e NEXT_PUBLIC_CONSOLE_BASE_URL=http://${CONSOLE_HOST}:${CONSOLE_PORT} \
		-e NEXT_PUBLIC_API_GATEWAY_URL=http://${API_GATEWAY_HOST}:${API_GATEWAY_PORT} \
		-e NEXT_SERVER_API_GATEWAY_URL=http://${API_GATEWAY_HOST}:${API_GATEWAY_PORT} \
		-e NEXT_PUBLIC_SELF_SIGNED_CERTIFICATION=false \
		-e NEXT_PUBLIC_INSTILL_AI_USER_COOKIE_NAME=instill-ai-user \
		--network ${COMPOSE_NETWORK_NAME} \
		--entrypoint ./entrypoint-playwright.sh \
		--name ${INSTILL_CORE_CONSOLE_INTEGRATION_TEST_CONTAINER_NAME}-latest \
		${INSTILL_CORE_CONSOLE_PLAYWRIGHT_IMAGE_NAME}:latest
	@make down

.PHONY: console-integration-test-release
console-integration-test-release:			# Run console integration test on the released Instill Core
	@make all EDITION=local-ce:test INSTILL_CORE_HOST=${API_GATEWAY_HOST} ENV_SECRETS_COMPONENT=${ENV_SECRETS_COMPONENT_TEST}
	@docker run --rm \
		-e NEXT_PUBLIC_GENERAL_API_VERSION=v1beta \
		-e NEXT_PUBLIC_MODEL_API_VERSION=v1alpha \
		-e NEXT_PUBLIC_CONSOLE_EDITION=local-ce:test \
		-e NEXT_PUBLIC_CONSOLE_BASE_URL=http://${CONSOLE_HOST}:${CONSOLE_PORT} \
		-e NEXT_PUBLIC_API_GATEWAY_URL=http://${API_GATEWAY_HOST}:${API_GATEWAY_PORT} \
		-e NEXT_SERVER_API_GATEWAY_URL=http://${API_GATEWAY_HOST}:${API_GATEWAY_PORT} \
		-e NEXT_PUBLIC_SELF_SIGNED_CERTIFICATION=false \
		-e NEXT_PUBLIC_INSTILL_AI_USER_COOKIE_NAME=instill-ai-user \
		--network ${COMPOSE_NETWORK_NAME} \
		--entrypoint ./entrypoint-playwright.sh \
		--name ${INSTILL_CORE_CONSOLE_INTEGRATION_TEST_CONTAINER_NAME}-release \
		${INSTILL_CORE_CONSOLE_PLAYWRIGHT_IMAGE_NAME}:${CONSOLE_VERSION}
	@make down

.PHONY: console-helm-integration-test-latest
console-helm-integration-test-latest:                       # Run console integration test on the Helm latest for Instill Core
	@make build-latest ENV_SECRETS_COMPONENT=${ENV_SECRETS_COMPONENT_TEST}
ifeq ($(UNAME_S),Darwin)
	@helm install ${HELM_RELEASE_NAME} charts/core --namespace ${HELM_NAMESPACE} --create-namespace \
		--set edition=k8s-ce:test \
		--set apiGateway.image.tag=latest \
		--set mgmtBackend.image.tag=latest \
		--set mgmtBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set artifactBackend.image.tag=latest \
		--set pipelineBackend.image.tag=latest \
		--set pipelineBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set modelBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set modelBackend.image.tag=latest \
		--set console.image.tag=latest \
		--set ray-cluster.image.tag=${RAY_LATEST_TAG} \
		--set apiGatewayURL=http://host.docker.internal:${API_GATEWAY_PORT} \
		--set console.serverApiGatewayURL=http://host.docker.internal:${API_GATEWAY_PORT} \
		--set consoleURL=http://host.docker.internal:${CONSOLE_PORT}
else ifeq ($(UNAME_S),Linux)
	@helm install ${HELM_RELEASE_NAME} charts/core --namespace ${HELM_NAMESPACE} --create-namespace \
		--set edition=k8s-ce:test \
		--set apiGateway.image.tag=latest \
		--set mgmtBackend.image.tag=latest \
		--set mgmtBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set artifactBackend.image.tag=latest \
		--set pipelineBackend.image.tag=latest \
		--set pipelineBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set modelBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set modelBackend.image.tag=latest \
		--set console.image.tag=latest \
		--set ray-cluster.image.tag=${RAY_LATEST_TAG} \
		--set apiGatewayURL=http://localhost:${API_GATEWAY_PORT} \
		--set console.serverApiGatewayURL=http://localhost:${API_GATEWAY_PORT} \
		--set consoleURL=http://localhost:${CONSOLE_PORT}
endif
	@kubectl rollout status deployment ${HELM_RELEASE_NAME}-api-gateway --namespace ${HELM_NAMESPACE} --timeout=600s
	@export API_GATEWAY_POD_NAME=$$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=api-gateway,app.kubernetes.io/instance=${HELM_RELEASE_NAME}" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl --namespace ${HELM_NAMESPACE} port-forward $${API_GATEWAY_POD_NAME} ${API_GATEWAY_PORT}:${API_GATEWAY_PORT} > /dev/null 2>&1 &
	@export CONSOLE_POD_NAME=$$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=console,app.kubernetes.io/instance=${HELM_RELEASE_NAME}" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl --namespace ${HELM_NAMESPACE} port-forward $${CONSOLE_POD_NAME} ${CONSOLE_PORT}:${CONSOLE_PORT} > /dev/null 2>&1 &
	@while ! nc -vz localhost ${API_GATEWAY_PORT} > /dev/null 2>&1; do sleep 1; done
	@while ! nc -vz localhost ${CONSOLE_PORT} > /dev/null 2>&1; do sleep 1; done
ifeq ($(UNAME_S),Darwin)
	@docker run --rm \
		-e NEXT_PUBLIC_CONSOLE_BASE_URL=http://host.docker.internal:${CONSOLE_PORT} \
		-e NEXT_PUBLIC_API_GATEWAY_URL=http://host.docker.internal:${API_GATEWAY_PORT} \
		-e NEXT_SERVER_API_GATEWAY_URL=http://host.docker.internal:${API_GATEWAY_PORT} \
		-e NEXT_PUBLIC_GENERAL_API_VERSION=v1beta \
		-e NEXT_PUBLIC_MODEL_API_VERSION=v1alpha \
		-e NEXT_PUBLIC_SELF_SIGNED_CERTIFICATION=false \
		-e NEXT_PUBLIC_INSTILL_AI_USER_COOKIE_NAME=instill-ai-user \
		-e NEXT_PUBLIC_CONSOLE_EDITION=k8s-ce:test \
		--entrypoint ./entrypoint-playwright.sh \
		--name ${INSTILL_CORE_CONSOLE_INTEGRATION_TEST_CONTAINER_NAME}-latest \
		${INSTILL_CORE_CONSOLE_PLAYWRIGHT_IMAGE_NAME}:latest
else ifeq ($(UNAME_S),Linux)
	@docker run --rm \
		-e NEXT_PUBLIC_CONSOLE_BASE_URL=http://localhost:${CONSOLE_PORT} \
		-e NEXT_PUBLIC_API_GATEWAY_URL=http://localhost:${API_GATEWAY_PORT} \
		-e NEXT_SERVER_API_GATEWAY_URL=http://localhost:${API_GATEWAY_PORT} \
		-e NEXT_PUBLIC_GENERAL_API_VERSION=v1beta \
		-e NEXT_PUBLIC_MODEL_API_VERSION=v1alpha \
		-e NEXT_PUBLIC_SELF_SIGNED_CERTIFICATION=false \
		-e NEXT_PUBLIC_INSTILL_AI_USER_COOKIE_NAME=instill-ai-user \
		-e NEXT_PUBLIC_CONSOLE_EDITION=k8s-ce:test \
		--network host \
		--entrypoint ./entrypoint-playwright.sh \
		--name ${INSTILL_CORE_CONSOLE_INTEGRATION_TEST_CONTAINER_NAME}-latest \
		${INSTILL_CORE_CONSOLE_PLAYWRIGHT_IMAGE_NAME}:latest
endif
	@helm uninstall ${HELM_RELEASE_NAME} --namespace ${HELM_NAMESPACE}
	@kubectl delete namespace instill-ai
	@pkill -f "port-forward"
	@make down

.PHONY: console-helm-integration-test-release
console-helm-integration-test-release:                       # Run console integration test on the Helm release for Instill Core
	@make build-release ENV_SECRETS_COMPONENT=${ENV_SECRETS_COMPONENT_TEST}
ifeq ($(UNAME_S),Darwin)
	@helm install ${HELM_RELEASE_NAME} charts/core --namespace ${HELM_NAMESPACE} --create-namespace \
		--set edition=k8s-ce:test \
		--set apiGateway.image.tag=${API_GATEWAY_VERSION} \
		--set mgmtBackend.image.tag=${MGMT_BACKEND_VERSION} \
		--set mgmtBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set artifactBackend.image.tag=${ARTIFACT_BACKEND_VERSION} \
		--set pipelineBackend.image.tag=${PIPELINE_BACKEND_VERSION} \
		--set pipelineBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set modelBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set modelBackend.image.tag=${MODEL_BACKEND_VERSION} \
		--set console.image.tag=${CONSOLE_VERSION} \
		--set ray-cluster.image.tag=${RAY_RELEASE_TAG} \
		--set apiGatewayURL=http://host.docker.internal:${API_GATEWAY_PORT} \
		--set console.serverApiGatewayURL=http://host.docker.internal:${API_GATEWAY_PORT} \
		--set consoleURL=http://host.docker.internal:${CONSOLE_PORT}
else ifeq ($(UNAME_S),Linux)
	@helm install ${HELM_RELEASE_NAME} charts/core --namespace ${HELM_NAMESPACE} --create-namespace \
		--set edition=k8s-ce:test \
		--set apiGateway.image.tag=${API_GATEWAY_VERSION} \
		--set mgmtBackend.image.tag=${MGMT_BACKEND_VERSION} \
		--set mgmtBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set artifactBackend.image.tag=${ARTIFACT_BACKEND_VERSION} \
		--set pipelineBackend.image.tag=${PIPELINE_BACKEND_VERSION} \
		--set pipelineBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set modelBackend.instillCoreHost=http://${INSTILL_CORE_HOST}:${API_GATEWAY_PORT} \
		--set modelBackend.image.tag=${MODEL_BACKEND_VERSION} \
		--set console.image.tag=${CONSOLE_VERSION} \
		--set ray-cluster.image.tag=${RAY_RELEASE_TAG} \
		--set apiGatewayURL=http://localhost:${API_GATEWAY_PORT} \
		--set console.serverApiGatewayURL=http://localhost:${API_GATEWAY_PORT} \
		--set consoleURL=http://localhost:${CONSOLE_PORT}
endif
	@kubectl rollout status deployment ${HELM_RELEASE_NAME}-api-gateway --namespace ${HELM_NAMESPACE} --timeout=600s
	@export API_GATEWAY_POD_NAME=$$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=api-gateway,app.kubernetes.io/instance=${HELM_RELEASE_NAME}" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl --namespace ${HELM_NAMESPACE} port-forward $${API_GATEWAY_POD_NAME} ${API_GATEWAY_PORT}:${API_GATEWAY_PORT} > /dev/null 2>&1 &
	@export CONSOLE_POD_NAME=$$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=console,app.kubernetes.io/instance=${HELM_RELEASE_NAME}" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl --namespace ${HELM_NAMESPACE} port-forward $${CONSOLE_POD_NAME} ${CONSOLE_PORT}:${CONSOLE_PORT} > /dev/null 2>&1 &
	@while ! nc -vz localhost ${API_GATEWAY_PORT} > /dev/null 2>&1; do sleep 1; done
	@while ! nc -vz localhost ${CONSOLE_PORT} > /dev/null 2>&1; do sleep 1; done
ifeq ($(UNAME_S),Darwin)
	@docker run --rm \
		-e NEXT_PUBLIC_CONSOLE_BASE_URL=http://host.docker.internal:${CONSOLE_PORT} \
		-e NEXT_PUBLIC_API_GATEWAY_URL=http://host.docker.internal:${API_GATEWAY_PORT} \
		-e NEXT_SERVER_API_GATEWAY_URL=http://host.docker.internal:${API_GATEWAY_PORT} \
		-e NEXT_PUBLIC_GENERAL_API_VERSION=v1beta \
		-e NEXT_PUBLIC_MODEL_API_VERSION=v1alpha \
		-e NEXT_PUBLIC_SELF_SIGNED_CERTIFICATION=false \
		-e NEXT_PUBLIC_INSTILL_AI_USER_COOKIE_NAME=instill-ai-user \
		-e NEXT_PUBLIC_CONSOLE_EDITION=k8s-ce:test \
		--entrypoint ./entrypoint-playwright.sh \
		--name ${INSTILL_CORE_CONSOLE_INTEGRATION_TEST_CONTAINER_NAME}-latest \
		${INSTILL_CORE_CONSOLE_PLAYWRIGHT_IMAGE_NAME}:${CONSOLE_VERSION}
else ifeq ($(UNAME_S),Linux)
	@docker run --rm \
		-e NEXT_PUBLIC_CONSOLE_BASE_URL=http://localhost:${CONSOLE_PORT} \
		-e NEXT_PUBLIC_API_GATEWAY_URL=http://localhost:${API_GATEWAY_PORT} \
		-e NEXT_SERVER_API_GATEWAY_URL=http://localhost:${API_GATEWAY_PORT} \
		-e NEXT_PUBLIC_GENERAL_API_VERSION=v1beta \
		-e NEXT_PUBLIC_MODEL_API_VERSION=v1alpha \
		-e NEXT_PUBLIC_SELF_SIGNED_CERTIFICATION=false \
		-e NEXT_PUBLIC_INSTILL_AI_USER_COOKIE_NAME=instill-ai-user \
		-e NEXT_PUBLIC_CONSOLE_EDITION=k8s-ce:test \
		--network host \
		--entrypoint ./entrypoint-playwright.sh \
		--name ${INSTILL_CORE_CONSOLE_INTEGRATION_TEST_CONTAINER_NAME}-latest \
		${INSTILL_CORE_CONSOLE_PLAYWRIGHT_IMAGE_NAME}:${CONSOLE_VERSION}
endif
	@helm uninstall ${HELM_RELEASE_NAME} --namespace ${HELM_NAMESPACE}
	@kubectl delete namespace instill-ai
	@pkill -f "port-forward"
	@make down

.PHONY: build-and-push-models
build-and-push-models:	# Helper target to build and push models
	@./integration-test/scripts/build_and_push_models.sh "$(PWD)/integration-test/models" "localhost:${REGISTRY_HOST_PORT}"

.PHONY: wait-models-deploy
wait-models-deploy:  # Helper target to wait for model deployment
	@model_count=$$(jq length integration-test/models/inventory.json); \
	timeout=600; elapsed=0; spinner='|/-\\'; i=0; \
	while [ "$$(curl -s http://localhost:8265/api/serve/applications/ | jq ".applications | to_entries | map(select(.key | contains(\"dummy-\")) | .value.status) | length == $$model_count and all(. == \"RUNNING\")")" != "true" ]; do \
		running_count=$$(curl -s http://localhost:8265/api/serve/applications/ | jq '.applications | to_entries | map(select(.key | contains("dummy-")) | .value.status) | map(select(. == "RUNNING")) | length'); \
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
	@printf "\nMake Application with Instill Core"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
