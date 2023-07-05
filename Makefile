.DEFAULT_GOAL:=help

#============================================================================

# load environment variables
include .env
export

UNAME_S := $(shell uname -s)

CONTAINER_BUILD_NAME := vdp-build
CONTAINER_COMPOSE_NAME := vdp-dind
CONTAINER_COMPOSE_IMAGE_NAME := instill/vdp-compose
CONTAINER_BACKEND_INTEGRATION_TEST_NAME := vdp-backend-integration-test
CONTAINER_CONSOLE_INTEGRATION_TEST_NAME := vdp-console-integration-test

HELM_NAMESPACE := instill-ai
HELM_RELEASE_NAME := vdp

#============================================================================

.PHONY: all
all:			## Launch all services with their up-to-date release version
ifeq ($(BASE_ENABLED), true)
	@export TMP_CONFIG_DIR=$(shell mktemp -d) && docker run -it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
		--name ${CONTAINER_COMPOSE_NAME}-release \
		${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
			cp -r /instill-ai/base/configs/* $${TMP_CONFIG_DIR} && \
			/bin/bash -c 'cd /instill-ai/base && make all EDITION=local-ce OBSERVE_ENABLED=${OBSERVE_ENABLED} OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' \
		" && rm -r $${TMP_CONFIG_DIR}
endif
	@EDITION=local-ce docker compose -f docker-compose.yml up -d --quiet-pull
	@EDITION=local-ce docker compose -f docker-compose.yml rm -f

.PHONY: latest
latest:			## Lunch all dependent services with their latest codebase
ifeq ($(BASE_ENABLED), true)
	@export TMP_CONFIG_DIR=$(shell mktemp -d) && docker run -it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
		--name ${CONTAINER_COMPOSE_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			cp -r /instill-ai/base/configs/* $${TMP_CONFIG_DIR} && \
			/bin/bash -c 'cd /instill-ai/base && make latest PROFILE=$(PROFILE) EDITION=local-ce:latest OBSERVE_ENABLED=${OBSERVE_ENABLED} OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' \
		" && rm -r $${TMP_CONFIG_DIR}
endif
	@COMPOSE_PROFILES=$(PROFILE) EDITION=local-ce:latest docker compose -f docker-compose.yml -f docker-compose.latest.yml up -d --quiet-pull
	@COMPOSE_PROFILES=$(PROFILE) EDITION=local-ce:latest docker compose -f docker-compose.yml -f docker-compose.latest.yml rm -f

.PHONY: logs
logs:			## Tail all logs with -n 10
	@docker compose logs --follow --tail=10

.PHONY: pull
pull:			## Pull all service images
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
	@docker rm -f ${CONTAINER_BUILD_NAME}-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BUILD_NAME}-release >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_CONSOLE_INTEGRATION_TEST_NAME}-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release >/dev/null 2>&1
	@docker rm -f ${CONTAINER_CONSOLE_INTEGRATION_TEST_NAME}-release >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_CONSOLE_INTEGRATION_TEST_NAME}-helm-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release >/dev/null 2>&1
	@docker rm -f ${CONTAINER_CONSOLE_INTEGRATION_TEST_NAME}-helm-release >/dev/null 2>&1
	@docker rm -f ${CONTAINER_COMPOSE_NAME}-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_COMPOSE_NAME}-release >/dev/null 2>&1
	@docker compose down -v
	@if docker compose ls -q | grep -q "instill-base"; then \
		docker run -it --rm \
			-v /var/run/docker.sock:/var/run/docker.sock \
			--name ${CONTAINER_COMPOSE_NAME} \
			${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
				/bin/bash -c 'cd /instill-ai/base && make down' \
			"; \
	fi

.PHONY: images
images:			## List all container images
	@docker compose images

.PHONY: ps
ps:				## List all service containers
	@docker compose ps

.PHONY: top
top:			## Display all running service processes
	@docker compose top

.PHONY: doc
doc:						## Run Redoc for OpenAPI spec at http://localhost:3001
	@docker compose up -d redoc_openapi

.PHONY: build-latest
build-latest:				## Build latest images for all VDP components
	@docker build --progress plain \
		--build-arg UBUNTU_VERSION=${UBUNTU_VERSION} \
		--build-arg GOLANG_VERSION=${GOLANG_VERSION} \
		--build-arg K6_VERSION=${K6_VERSION} \
		--build-arg CACHE_DATE="$(shell date)" \
		--target latest \
		-t ${CONTAINER_COMPOSE_IMAGE_NAME}:latest .
	@docker run -it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${BUILD_CONFIG_DIR_PATH}/.env:/instill-ai/vdp/.env \
		-v ${BUILD_CONFIG_DIR_PATH}/docker-compose.build.yml:/instill-ai/vdp/docker-compose.build.yml \
		--name ${CONTAINER_BUILD_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			API_GATEWAY_VDP_VERSION=latest \
			PIPELINE_BACKEND_VERSION=latest \
			CONNECTOR_BACKEND_VERSION=latest \
			CONTROLLER_VDP_VERSION=latest \
			docker compose -f docker-compose.build.yml build --progress plain \
		"

.PHONY: build-release
build-release:				## Build release images for all VDP components
	@docker build --progress plain \
		--build-arg UBUNTU_VERSION=${UBUNTU_VERSION} \
		--build-arg GOLANG_VERSION=${GOLANG_VERSION} \
		--build-arg K6_VERSION=${K6_VERSION} \
		--build-arg CACHE_DATE="$(shell date)" \
		--build-arg API_GATEWAY_VDP_VERSION=${API_GATEWAY_VDP_VERSION} \
		--build-arg PIPELINE_BACKEND_VERSION=${PIPELINE_BACKEND_VERSION} \
		--build-arg CONNECTOR_BACKEND_VERSION=${CONNECTOR_BACKEND_VERSION} \
		--build-arg CONTROLLER_VDP_VERSION=${CONTROLLER_VDP_VERSION} \
		--target release \
		-t ${CONTAINER_COMPOSE_IMAGE_NAME}:release .
	@docker run -it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${BUILD_CONFIG_DIR_PATH}/.env:/instill-ai/vdp/.env \
		-v ${BUILD_CONFIG_DIR_PATH}/docker-compose.build.yml:/instill-ai/vdp/docker-compose.build.yml \
		--name ${CONTAINER_BUILD_NAME}-release \
		${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
			API_GATEWAY_VDP_VERSION=${API_GATEWAY_VDP_VERSION} \
			PIPELINE_BACKEND_VERSION=${PIPELINE_BACKEND_VERSION} \
			CONNECTOR_BACKEND_VERSION=${CONNECTOR_BACKEND_VERSION} \
			CONTROLLER_VDP_VERSION=${CONTROLLER_VDP_VERSION} \
			docker compose -f docker-compose.build.yml build --progress plain \
		"

.PHONY: integration-test-latest
integration-test-latest:			## Run integration test on the latest VDP
	@make build-latest
	@export TMP_CONFIG_DIR=$(shell mktemp -d) && docker run -it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			cp /instill-ai/base/.env $${TMP_CONFIG_DIR}/.env && \
			cp /instill-ai/base/docker-compose.build.yml $${TMP_CONFIG_DIR}/docker-compose.build.yml && \
			cp -r /instill-ai/base/configs/influxdb $${TMP_CONFIG_DIR} && \
			/bin/bash -c 'cd /instill-ai/base && make build-latest BUILD_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' && \
			/bin/bash -c 'cd /instill-ai/base && make latest PROFILE=all EDITION=local-ce:test OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' \
		" && rm -r $${TMP_CONFIG_DIR}
	@COMPOSE_PROFILES=all EDITION=local-ce:test docker compose -f docker-compose.yml -f docker-compose.latest.yml up -d --quiet-pull
	@COMPOSE_PROFILES=all EDITION=local-ce:test docker compose -f docker-compose.yml -f docker-compose.latest.yml rm -f
	@docker run -it --rm \
		--network instill-network \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd pipeline-backend && make integration-test API_GATEWAY_VDP_HOST=${API_GATEWAY_VDP_HOST} API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' && \
			/bin/bash -c 'cd connector-backend && make integration-test API_GATEWAY_VDP_HOST=${API_GATEWAY_VDP_HOST} API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' && \
			/bin/bash -c 'cd controller-vdp && make integration-test API_GATEWAY_VDP_HOST=${API_GATEWAY_VDP_HOST} API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' \
		"
	@make down

.PHONY: integration-test-release
integration-test-release:			## Run integration test on the release VDP
	@make build-release
	@export TMP_CONFIG_DIR=$(shell mktemp -d) && docker run -it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release \
		${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
			cp /instill-ai/base/.env $${TMP_CONFIG_DIR}/.env && \
			cp /instill-ai/base/docker-compose.build.yml $${TMP_CONFIG_DIR}/docker-compose.build.yml && \
			cp -r /instill-ai/base/configs/influxdb $${TMP_CONFIG_DIR} && \
			/bin/bash -c 'cd /instill-ai/base && make build-release BUILD_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' && \
			/bin/bash -c 'cd /instill-ai/base && make all EDITION=local-ce:test OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' \
		" && rm -r $${TMP_CONFIG_DIR}
	@EDITION=local-ce:test ITMODE_ENABLED=true docker compose up -d --quiet-pull
	@EDITION=local-ce:test docker compose rm -f
	@docker run -it --rm \
		--network instill-network \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release \
		${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
			/bin/bash -c 'cd pipeline-backend && make integration-test API_GATEWAY_VDP_HOST=${API_GATEWAY_VDP_HOST} API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' && \
			/bin/bash -c cd connector-backend && make integration-test API_GATEWAY_VDP_HOST=${API_GATEWAY_VDP_HOST} API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT} && \
			/bin/bash -c 'cd controller-vdp && make integration-test API_GATEWAY_VDP_HOST=${API_GATEWAY_VDP_HOST} API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' \
		"
	@make down

.PHONY: helm-integration-test-latest
helm-integration-test-latest:                       ## Run integration test on the Helm latest for VDP
	@make build-latest
	@docker run -it --rm \
		-v ${HOME}/.kube/config:/instill-ai/kubeconfig \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd /instill-ai/base && \
				helm --kubeconfig /instill-ai/kubeconfig install base charts/base \
					--namespace instill-ai --create-namespace \
					--set edition=k8s-ce:test \
					--set apiGatewayBase.image.tag=latest \
					--set mgmtBackend.image.tag=latest \
					--set console.image.tag=latest \
					--set tags.observability=false && \
				kubectl rollout status deployment base-api-gateway-base -n instill-ai --timeout=120s --kubeconfig /instill-ai/kubeconfig' \
		"
	@helm install vdp charts/vdp --namespace instill-ai --create-namespace \
		--set edition=k8s-ce:test \
		--set apiGatewayVDP.image.tag=latest \
		--set pipelineBackend.image.tag=latest \
		--set connectorBackend.image.tag=latest \
		--set controllerVDP.image.tag=latest \
		--set tags.observability=false
	@kubectl rollout status deployment vdp-api-gateway-vdp -n instill-ai --timeout=120s
	@export API_GATEWAY_VDP_POD_NAME=$$(kubectl get pods --namespace instill-ai -l "app.kubernetes.io/component=api-gateway-vdp,app.kubernetes.io/instance=${HELM_RELEASE_NAME}" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl --namespace instill-ai port-forward $${API_GATEWAY_VDP_POD_NAME} ${API_GATEWAY_VDP_PORT}:${API_GATEWAY_VDP_PORT} > /dev/null 2>&1 &
	@while ! nc -vz localhost ${API_GATEWAY_VDP_PORT} > /dev/null 2>&1; do sleep 1; done
ifeq ($(UNAME_S),Darwin)
	@docker run -it --rm -p ${API_GATEWAY_VDP_PORT}:${API_GATEWAY_VDP_PORT} --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest ${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd pipeline-backend && make integration-test API_GATEWAY_VDP_HOST=host.docker.internal API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' && \
			/bin/bash -c 'cd connector-backend && make integration-test API_GATEWAY_VDP_HOST=host.docker.internal API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' && \
			/bin/bash -c 'cd controller-vdp && make integration-test API_GATEWAY_VDP_HOST=host.docker.internal API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' \
		"
else ifeq ($(UNAME_S),Linux)
	@docker run -it --rm --network host --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest ${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd pipeline-backend && make integration-test API_GATEWAY_VDP_HOST=localhost API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' && \
			/bin/bash -c 'cd connector-backend && make integration-test API_GATEWAY_VDP_HOST=localhost API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' && \
			/bin/bash -c 'cd controller-vdp && make integration-test API_GATEWAY_VDP_HOST=host.docker.internal API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' \
		"
endif
	@helm uninstall vdp --namespace instill-ai
	@docker run -it --rm \
		-v ${HOME}/.kube/config:/instill-ai/kubeconfig \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd /instill-ai/base && helm --kubeconfig /instill-ai/kubeconfig uninstall base --namespace instill-ai' \
		"
	@kubectl delete namespace instill-ai
	@pkill -f "port-forward"
	@make down

.PHONY: helm-integration-test-release
helm-integration-test-release:                       ## Run integration test on the Helm release for VDP
	@make build-release
	@docker run -it --rm \
		-v ${HOME}/.kube/config:/instill-ai/kubeconfig \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd /instill-ai/base && \
				export $(grep -v '^#' .env | xargs) && \
				helm --kubeconfig /instill-ai/kubeconfig install base charts/base \
					--namespace instill-ai --create-namespace \
					--set edition=k8s-ce:test \
					--set apiGatewayBase.image.tag=$${API_GATEWAY_BASE_VERSION} \
					--set mgmtBackend.image.tag=$${MGMT_BACKEND_VERSION} \
					--set console.image.tag=$${CONSOLE_VERSION} \
					--set tags.observability=false && \
				kubectl rollout status deployment base-api-gateway-base -n instill-ai --timeout=120s --kubeconfig /instill-ai/kubeconfig' \
		"
	@helm install vdp charts/vdp --namespace instill-ai --create-namespace \
		--set edition=k8s-ce:test \
		--set apiGatewayVDP.image.tag=${API_GATEWAY_VDP_VERSION} \
		--set pipelineBackend.image.tag=${PIPELINE_BACKEND_VERSION} \
		--set connectorBackend.image.tag=${CONNECTOR_BACKEND_VERSION} \
		--set controllerVDP.image.tag=${CONTROLLER_VDP_VERSION} \
		--set tags.observability=false
	@kubectl rollout status deployment vdp-api-gateway-vdp -n instill-ai --timeout=120s
	@export API_GATEWAY_VDP_POD_NAME=$$(kubectl get pods --namespace instill-ai -l "app.kubernetes.io/component=api-gateway-vdp,app.kubernetes.io/instance=${HELM_RELEASE_NAME}" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl --namespace instill-ai port-forward $${API_GATEWAY_VDP_POD_NAME} ${API_GATEWAY_VDP_PORT}:${API_GATEWAY_VDP_PORT} > /dev/null 2>&1 &
	@while ! nc -vz localhost ${API_GATEWAY_VDP_PORT} > /dev/null 2>&1; do sleep 1; done
ifeq ($(UNAME_S),Darwin)
	@docker run -it --rm -p ${API_GATEWAY_VDP_PORT}:${API_GATEWAY_VDP_PORT} --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release ${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
			/bin/bash -c 'cd pipeline-backend && make integration-test API_GATEWAY_VDP_HOST=host.docker.internal API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' && \
			/bin/bash -c 'cd connector-backend && make integration-test API_GATEWAY_VDP_HOST=host.docker.internal API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' && \
			/bin/bash -c 'cd controller-vdp && make integration-test API_GATEWAY_VDP_HOST=host.docker.internal API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' \
		"
else ifeq ($(UNAME_S),Linux)
	@docker run -it --rm --network host --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release ${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
			/bin/bash -c 'cd pipeline-backend && make integration-test API_GATEWAY_VDP_HOST=localhost API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' && \
			/bin/bash -c 'cd connector-backend && make integration-test API_GATEWAY_VDP_HOST=localhost API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' && \
			/bin/bash -c 'cd controller-vdp && make integration-test API_GATEWAY_VDP_HOST=host.docker.internal API_GATEWAY_VDP_PORT=${API_GATEWAY_VDP_PORT}' \
		"
endif
	@helm uninstall vdp --namespace instill-ai
	@docker run -it --rm \
		-v ${HOME}/.kube/config:/instill-ai/kubeconfig \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd /instill-ai/base && helm --kubeconfig /instill-ai/kubeconfig uninstall base --namespace instill-ai' \
		"
	@kubectl delete namespace instill-ai
	@pkill -f "port-forward"
	@make down

.PHONY: help
help:       	## Show this help
	@echo "\nMake Application with Docker Compose"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
