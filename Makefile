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

HELM_NAMESPACE := instill-ai
HELM_RELEASE_NAME := vdp

# check or generate uuid for user
ifeq ($(wildcard ${SYSTEM_CONFIG_PATH}/user_uid),)
$(shell mkdir -p ${SYSTEM_CONFIG_PATH})
$(shell docker run --rm andyneff/uuidgen > ${SYSTEM_CONFIG_PATH}/user_uid)
endif
DEFAULT_USER_UID := $(shell cat ${SYSTEM_CONFIG_PATH}/user_uid)

#============================================================================

.PHONY: all
all:			## Launch all services with their up-to-date release version
	@make build-release
	@if ! (docker compose ls -q | grep -q "instill-base"); then \
		export TMP_CONFIG_DIR=$(shell mktemp -d) && \
		docker run -it --rm \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
			--name ${CONTAINER_COMPOSE_NAME}-release \
			${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
				cp /instill-ai/base/.env $${TMP_CONFIG_DIR}/.env && \
				cp /instill-ai/base/docker-compose.build.yml $${TMP_CONFIG_DIR}/docker-compose.build.yml && \
				cp -r /instill-ai/base/configs/influxdb $${TMP_CONFIG_DIR} && \
				/bin/bash -c 'cd /instill-ai/base && make build-release BUILD_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' && \
				/bin/bash -c 'cd /instill-ai/base && DEFAULT_USER_UID=${DEFAULT_USER_UID} EDITION=local-ce:test OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} docker compose up -d --quiet-pull' && \
				/bin/bash -c 'cd /instill-ai/base && EDITION=local-ce:test OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} docker compose rm -f' && \
				/bin/bash -c 'rm -rf $${TMP_CONFIG_DIR}/*' \
			" && \
		rm -rf $${TMP_CONFIG_DIR}; \
	fi
	@EDITION=local-ce docker compose -f docker-compose.yml up -d --quiet-pull
	@EDITION=local-ce docker compose -f docker-compose.yml rm -f

.PHONY: latest
latest:			## Lunch all dependent services with their latest codebase
	@make build-latest
	@if ! (docker compose ls -q | grep -q "instill-base"); then \
		export TMP_CONFIG_DIR=$(shell mktemp -d) && \
		docker run -it --rm \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
			--name ${CONTAINER_COMPOSE_NAME}-latest \
			${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
				cp /instill-ai/base/.env $${TMP_CONFIG_DIR}/.env && \
				cp /instill-ai/base/docker-compose.build.yml $${TMP_CONFIG_DIR}/docker-compose.build.yml && \
				cp -r /instill-ai/base/configs/influxdb $${TMP_CONFIG_DIR} && \
				/bin/bash -c 'cd /instill-ai/base && make build-latest BUILD_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' && \
				/bin/bash -c 'cd /instill-ai/base && DEFAULT_USER_UID=${DEFAULT_USER_UID} COMPOSE_PROFILES=all EDITION=local-ce:test OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} docker compose -f docker-compose.yml -f docker-compose.latest.yml up -d --quiet-pull' && \
				/bin/bash -c 'cd /instill-ai/base && COMPOSE_PROFILES=all EDITION=local-ce:test OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} docker compose -f docker-compose.yml -f docker-compose.latest.yml rm -f' && \
				/bin/bash -c 'rm -rf $${TMP_CONFIG_DIR}/*' \
			" && \
		rm -rf $${TMP_CONFIG_DIR}; \
	fi
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
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release >/dev/null 2>&1
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
		--build-arg BASE_VERSION=${BASE_VERSION} \
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
			BASE_VERSION=${BASE_VERSION} \
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
			/bin/bash -c 'cd /instill-ai/base && COMPOSE_PROFILES=all EDITION=local-ce:test OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} docker compose -f docker-compose.yml -f docker-compose.latest.yml up -d --quiet-pull' && \
			/bin/bash -c 'cd /instill-ai/base && COMPOSE_PROFILES=all EDITION=local-ce:test OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} docker compose -f docker-compose.yml -f docker-compose.latest.yml rm -f' && \
			/bin/bash -c 'rm -rf $${TMP_CONFIG_DIR}/*' \
		" && rm -rf $${TMP_CONFIG_DIR}
	@COMPOSE_PROFILES=all EDITION=local-ce:test docker compose -f docker-compose.yml -f docker-compose.latest.yml up -d --quiet-pull
	@COMPOSE_PROFILES=all EDITION=local-ce:test docker compose -f docker-compose.yml -f docker-compose.latest.yml rm -f
	@docker run -it --rm \
		--network instill-network \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd pipeline-backend && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT}' && \
			/bin/bash -c 'cd connector-backend && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT}' && \
			/bin/bash -c 'cd controller-vdp && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT}' \
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
			/bin/bash -c 'cd /instill-ai/base && EDITION=local-ce:test OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} docker compose up -d --quiet-pull' && \
			/bin/bash -c 'cd /instill-ai/base && EDITION=local-ce:test OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} docker compose rm -f' && \
			/bin/bash -c 'rm -rf $${TMP_CONFIG_DIR}/*' \
		" && rm -rf $${TMP_CONFIG_DIR}
	@EDITION=local-ce:test ITMODE_ENABLED=true docker compose up -d --quiet-pull
	@EDITION=local-ce:test docker compose rm -f
	@docker run -it --rm \
		--network instill-network \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release \
		${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
			/bin/bash -c 'cd pipeline-backend && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT}' && \
			/bin/bash -c 'cd connector-backend && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT}' && \
			/bin/bash -c 'cd controller-vdp && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT}' \
		"
	@make down

.PHONY: helm-integration-test-latest
helm-integration-test-latest:                       ## Run integration test on the Helm latest for VDP
	@make build-latest
	@export TMP_CONFIG_DIR=$(shell mktemp -d) && docker run -it --rm \
		-v ${HOME}/.kube/config:/root/.kube/config \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
		${DOCKER_HELM_IT_EXTRA_PARAMS} \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			cp /instill-ai/base/.env $${TMP_CONFIG_DIR}/.env && \
			cp /instill-ai/base/docker-compose.build.yml $${TMP_CONFIG_DIR}/docker-compose.build.yml && \
			/bin/bash -c 'cd /instill-ai/base && make build-latest BUILD_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' && \
			/bin/bash -c 'cd /instill-ai/base && \
				helm install base charts/base \
					--namespace ${HELM_NAMESPACE} --create-namespace \
					--set edition=k8s-ce:test \
					--set apiGateway.image.tag=latest \
					--set mgmtBackend.image.tag=latest \
					--set console.image.tag=latest \
					--set tags.observability=false \
					--set tags.prometheusStack=false' \
			/bin/bash -c 'rm -rf $${TMP_CONFIG_DIR}/*' \
		" && rm -rf $${TMP_CONFIG_DIR}
	@kubectl rollout status deployment base-api-gateway --namespace ${HELM_NAMESPACE} --timeout=120s
	@export API_GATEWAY_POD_NAME=$$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=api-gateway,app.kubernetes.io/instance=base" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl --namespace ${HELM_NAMESPACE} port-forward $${API_GATEWAY_POD_NAME} ${API_GATEWAY_PORT}:${API_GATEWAY_PORT} > /dev/null 2>&1 &
	@while ! nc -vz localhost ${API_GATEWAY_PORT} > /dev/null 2>&1; do sleep 1; done
	@helm install ${HELM_RELEASE_NAME} charts/vdp --namespace ${HELM_NAMESPACE} --create-namespace \
		--set edition=k8s-ce:test \
		--set pipelineBackend.image.tag=latest \
		--set connectorBackend.image.tag=latest \
		--set controllerVDP.image.tag=latest \
		--set tags.observability=false
	@kubectl rollout status deployment vdp-connector-backend --namespace ${HELM_NAMESPACE} --timeout=120s
	@kubectl rollout status deployment vdp-pipeline-backend --namespace ${HELM_NAMESPACE} --timeout=120s
	@kubectl rollout status deployment vdp-controller-vdp --namespace ${HELM_NAMESPACE} --timeout=120s
	@sleep 10
ifeq ($(UNAME_S),Darwin)
	@docker run -it --rm --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest ${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd pipeline-backend && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' && \
			/bin/bash -c 'cd connector-backend && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' && \
			/bin/bash -c 'cd controller-vdp && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' \
		"
else ifeq ($(UNAME_S),Linux)
	@docker run -it --rm --network host --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest ${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd pipeline-backend && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' && \
			/bin/bash -c 'cd connector-backend && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' && \
			/bin/bash -c 'cd controller-vdp && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' \
		"
endif
	@helm uninstall ${HELM_RELEASE_NAME} --namespace ${HELM_NAMESPACE}
	@docker run -it --rm \
		-v ${HOME}/.kube/config:/root/.kube/config \
		${DOCKER_HELM_IT_EXTRA_PARAMS} \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd /instill-ai/base && helm uninstall base --namespace ${HELM_NAMESPACE}' \
		"
	@kubectl delete namespace instill-ai
	@pkill -f "port-forward"
	@make down

.PHONY: helm-integration-test-release
helm-integration-test-release:                       ## Run integration test on the Helm release for VDP
	@make build-release
	@docker run -it --rm \
		-v ${HOME}/.kube/config:/root/.kube/config \
		${DOCKER_HELM_IT_EXTRA_PARAMS} \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd /instill-ai/base && \
				export $(grep -v '^#' .env | xargs) && \
				helm install base charts/base \
					--namespace ${HELM_NAMESPACE} --create-namespace \
					--set edition=k8s-ce:test \
					--set tags.observability=false \
					--set tags.prometheusStack=false' \
			/bin/bash -c 'rm -rf $${TMP_CONFIG_DIR}/*' \
		" && rm -rf $${TMP_CONFIG_DIR}
	@kubectl rollout status deployment base-api-gateway --namespace ${HELM_NAMESPACE} --timeout=120s
	@export API_GATEWAY_POD_NAME=$$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=api-gateway,app.kubernetes.io/instance=base" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl --namespace ${HELM_NAMESPACE} port-forward $${API_GATEWAY_POD_NAME} ${API_GATEWAY_PORT}:${API_GATEWAY_PORT} > /dev/null 2>&1 &
	@while ! nc -vz localhost ${API_GATEWAY_PORT} > /dev/null 2>&1; do sleep 1; done
	@helm install ${HELM_RELEASE_NAME} charts/vdp --namespace ${HELM_NAMESPACE} --create-namespace \
		--set edition=k8s-ce:test \
		--set pipelineBackend.image.tag=${PIPELINE_BACKEND_VERSION} \
		--set connectorBackend.image.tag=${CONNECTOR_BACKEND_VERSION} \
		--set controllerVDP.image.tag=${CONTROLLER_VDP_VERSION} \
		--set tags.observability=false
	@kubectl rollout status deployment vdp-connector-backend --namespace ${HELM_NAMESPACE} --timeout=120s
	@kubectl rollout status deployment vdp-pipeline-backend --namespace ${HELM_NAMESPACE} --timeout=120s
	@kubectl rollout status deployment vdp-controller-vdp --namespace ${HELM_NAMESPACE} --timeout=120s
	@sleep 10
ifeq ($(UNAME_S),Darwin)
	@docker run -it --rm --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release ${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
			/bin/bash -c 'cd pipeline-backend && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' && \
			/bin/bash -c 'cd connector-backend && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' && \
			/bin/bash -c 'cd controller-vdp && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' \
		"
else ifeq ($(UNAME_S),Linux)
	@docker run -it --rm --network host --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release ${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
			/bin/bash -c 'cd pipeline-backend && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' && \
			/bin/bash -c 'cd connector-backend && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' && \
			/bin/bash -c 'cd controller-vdp && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' \
		"
endif
	@helm uninstall ${HELM_RELEASE_NAME} --namespace ${HELM_NAMESPACE}
	@docker run -it --rm \
		-v ${HOME}/.kube/config:/root/.kube/config \
		${DOCKER_HELM_IT_EXTRA_PARAMS} \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd /instill-ai/base && helm uninstall base --namespace ${HELM_NAMESPACE}' \
		"
	@kubectl delete namespace instill-ai
	@pkill -f "port-forward"
	@make down

.PHONY: help
help:       	## Show this help
	@echo "\nMake Application with Docker Compose"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
