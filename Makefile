.DEFAULT_GOAL:=help

#============================================================================

# load environment variables
include .env
export

TRITON_CONDA_ENV_PLATFORM := cpu
TRITON_NVIDIA_VISIBLE_DEVICES := 
ifeq ($(shell nvidia-smi 2>/dev/null 1>&2; echo $$?),0)
	TRITONSERVER_RUNTIME := nvidia
	TRITON_CONDA_ENV_PLATFORM := gpu
	TRITON_NVIDIA_VISIBLE_DEVICES := all
endif

UNAME_S := $(shell uname -s)

#============================================================================

.PHONY: all
all:			## Launch all services with their up-to-date release version
	@docker inspect --type=image instill/tritonserver:${TRITON_SERVER_VERSION} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@EDITION=local-ce docker compose up -d --quiet-pull
	@EDITION=local-ce docker compose rm -f

.PHONY: latest
latest:			## Lunch all dependent services with their latest codebase
	@docker inspect --type=image instill/tritonserver:${TRITON_SERVER_VERSION} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@COMPOSE_PROFILES=$(PROFILE) EDITION=local-ce:latest docker compose -f docker-compose.yml -f docker-compose.latest.yml up -d --quiet-pull
	@COMPOSE_PROFILES=$(PROFILE) EDITION=local-ce:latest docker compose -f docker-compose.yml -f docker-compose.latest.yml rm -f

.PHONY: logs
logs:			## Tail all logs with -n 10
	@docker compose logs --follow --tail=10

.PHONY: pull
pull:			## Pull all service images
	@docker inspect --type=image instill/tritonserver:${TRITON_SERVER_VERSION} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
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
	@docker rm -f vdp-build-latest >/dev/null 2>&1
	@docker rm -f vdp-build-release >/dev/null 2>&1
	@docker rm -f backend-integration-test-latest >/dev/null 2>&1
	@docker rm -f console-integration-test-latest >/dev/null 2>&1
	@docker rm -f backend-integration-test-release >/dev/null 2>&1
	@docker rm -f console-integration-test-release >/dev/null 2>&1
	@docker rm -f backend-helm-integration-test-latest >/dev/null 2>&1
	@docker rm -f console-helm-integration-test-latest >/dev/null 2>&1
	@docker rm -f backend-helm-integration-test-release >/dev/null 2>&1
	@docker rm -f console-helm-integration-test-release >/dev/null 2>&1
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
		-t instill/vdp-compose:latest .
	@docker run -it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${PWD}/.env:/vdp/.env \
		-v ${PWD}/docker-compose.build.yml:/vdp/docker-compose.build.yml \
		--name vdp-build-latest \
		instill/vdp-compose:latest /bin/bash -c " \
		API_GATEWAY_VERSION=latest \
		PIPELINE_BACKEND_VERSION=latest \
		CONNECTOR_BACKEND_VERSION=latest \
		MODEL_BACKEND_VERSION=latest \
		MGMT_BACKEND_VERSION=latest \
		CONTROLLER_VERSION=latest \
		CONSOLE_VERSION=latest \
		docker compose -f docker-compose.build.yml build --progress plain \
		"

.PHONY: build-release
build-release:				## Build release images for all VDP components
	@docker build --progress plain \
		--build-arg UBUNTU_VERSION=${UBUNTU_VERSION} \
		--build-arg GOLANG_VERSION=${GOLANG_VERSION} \
		--build-arg K6_VERSION=${K6_VERSION} \
		--build-arg CACHE_DATE="$(shell date)" \
		--build-arg API_GATEWAY_VERSION=${API_GATEWAY_VERSION} \
		--build-arg PIPELINE_BACKEND_VERSION=${PIPELINE_BACKEND_VERSION} \
		--build-arg CONNECTOR_BACKEND_VERSION=${CONNECTOR_BACKEND_VERSION} \
		--build-arg MODEL_BACKEND_VERSION=${MODEL_BACKEND_VERSION} \
		--build-arg MGMT_BACKEND_VERSION=${MGMT_BACKEND_VERSION} \
		--build-arg CONTROLLER_VERSION=${CONTROLLER_VERSION} \
		--build-arg CONSOLE_VERSION=${CONSOLE_VERSION} \
		--target release \
		-t instill/vdp-compose:release .
	@docker run -it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${PWD}/.env:/vdp/.env \
		-v ${PWD}/docker-compose.build.yml:/vdp/docker-compose.build.yml \
		--name vdp-build-release \
		instill/vdp-compose:release /bin/bash -c " \
		API_GATEWAY_VERSION=${API_GATEWAY_VERSION} \
		PIPELINE_BACKEND_VERSION=${PIPELINE_BACKEND_VERSION} \
		CONNECTOR_BACKEND_VERSION=${CONNECTOR_BACKEND_VERSION} \
		MODEL_BACKEND_VERSION=${MODEL_BACKEND_VERSION} \
		MGMT_BACKEND_VERSION=${MGMT_BACKEND_VERSION} \
		CONTROLLER_VERSION=${CONTROLLER_VERSION} \
		CONSOLE_VERSION=${CONSOLE_VERSION} \
		docker compose -f docker-compose.build.yml build --progress plain \
		"

.PHONY: integration-test-latest
integration-test-latest:			## Run integration test on the latest VDP
	@make build-latest
	@COMPOSE_PROFILES=all EDITION=local-ce:test ITMODE=true CONSOLE_BASE_URL_HOST=console CONSOLE_BASE_API_GATEWAY_URL_HOST=api-gateway \
		docker compose -f docker-compose.yml -f docker-compose.latest.yml up -d --quiet-pull
	@COMPOSE_PROFILES=all EDITION=local-ce:test docker compose -f docker-compose.yml -f docker-compose.latest.yml rm -f
	@docker run -it --rm \
		--network instill-network \
		--name backend-integration-test-latest \
		instill/vdp-compose:latest /bin/bash -c " \
		cd pipeline-backend && make integration-test API_GATEWAY_HOST=api-gateway API_GATEWAY_PORT=8080 && cd ~- && \
		cd connector-backend && make integration-test API_GATEWAY_HOST=api-gateway API_GATEWAY_PORT=8080 && cd ~- && \
		cd model-backend && make integration-test API_GATEWAY_HOST=api-gateway API_GATEWAY_PORT=8080 && cd ~- && \
		cd mgmt-backend && make integration-test API_GATEWAY_HOST=api-gateway API_GATEWAY_PORT=8080 && cd ~- \
		"
	@docker run -it --rm \
		-e NEXT_PUBLIC_CONSOLE_BASE_URL=http://console:3000 \
		-e NEXT_PUBLIC_API_GATEWAY_BASE_URL=http://api-gateway:8080 \
		-e NEXT_PUBLIC_API_VERSION=v1alpha \
		-e NEXT_PUBLIC_SELF_SIGNED_CERTIFICATION=false \
		-e NEXT_PUBLIC_INSTILL_AI_USER_COOKIE_NAME=instill-ai-user \
		-e NEXT_PUBLIC_CONSOLE_EDITION=local-ce:test \
		--network instill-network \
		--entrypoint ./entrypoint-playwright.sh \
		--name console-integration-test-latest \
		instill/console-playwright:latest
	@make down

.PHONY: integration-test-release
integration-test-release:			## Run integration test on the release VDP
	@make build-release
	@EDITION=local-ce:test ITMODE=true CONSOLE_BASE_URL_HOST=console CONSOLE_BASE_API_GATEWAY_URL_HOST=api-gateway \
		docker compose up -d --quiet-pull
	@EDITION=local-ce:test docker compose rm -f
	@docker run -it --rm \
		--network instill-network \
		--name backend-integration-test-release \
		instill/vdp-compose:release /bin/bash -c " \
		cd pipeline-backend && make integration-test API_GATEWAY_HOST=api-gateway API_GATEWAY_PORT=8080 && cd ~- && \
		cd connector-backend && make integration-test API_GATEWAY_HOST=api-gateway API_GATEWAY_PORT=8080 && cd ~- && \
		cd model-backend && make integration-test API_GATEWAY_HOST=api-gateway API_GATEWAY_PORT=8080 && cd ~- && \
		cd mgmt-backend && make integration-test API_GATEWAY_HOST=api-gateway API_GATEWAY_PORT=8080 && cd ~- \
		"
	@docker run -it --rm \
		-e NEXT_PUBLIC_CONSOLE_BASE_URL=http://console:3000 \
		-e NEXT_PUBLIC_API_GATEWAY_BASE_URL=http://api-gateway:8080 \
		-e NEXT_PUBLIC_API_VERSION=v1alpha \
		-e NEXT_PUBLIC_SELF_SIGNED_CERTIFICATION=false \
		-e NEXT_PUBLIC_INSTILL_AI_USER_COOKIE_NAME=instill-ai-user \
		-e NEXT_PUBLIC_CONSOLE_EDITION=local-ce:test \
		--network instill-network \
		--entrypoint ./entrypoint-playwright.sh \
		--name console-integration-test-release \
		instill/console-playwright:${CONSOLE_VERSION}
	@make down

.PHONY: helm-integration-test-latest
helm-integration-test-latest:                       ## Run integration test on the Helm latest for VDP
ifeq ($(UNAME_S),Darwin)
	@make build-latest
	@helm install vdp charts/vdp --devel --namespace vdp --create-namespace \
		--set itMode=true \
		--set edition=k8s-ce:test \
		--set apigateway.image.tag=latest \
		--set pipeline.image.tag=latest \
		--set connector.image.tag=latest \
		--set model.image.tag=latest \
		--set mgmt.image.tag=latest \
		--set controller.image.tag=latest \
		--set console.image.tag=latest \
		--set triton.nvidiaVisibleDevices=${TRITON_NVIDIA_VISIBLE_DEVICES} \
		--set apigatewayURL=http://host.docker.internal:8080 \
		--set consoleURL=http://host.docker.internal:3000 \
		--set console.serverApiGatewayBaseUrl=http://host.docker.internal:8080
	@sleep 1
	@export CONTROLLER_POD_NAME=$$(kubectl get pods --namespace vdp -l "app.kubernetes.io/component=controller,app.kubernetes.io/instance=vdp" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl wait --for=condition=Ready pod $$CONTROLLER_POD_NAME -n vdp --timeout=300s || true
	@export APIGATEWAY_POD_NAME=$$(kubectl get pods --namespace vdp -l "app.kubernetes.io/component=api-gateway,app.kubernetes.io/instance=vdp" -o jsonpath="{.items[0].metadata.name}") && \
		export APIGATEWAY_CONTAINER_PORT=$$(kubectl get pod --namespace vdp $$APIGATEWAY_POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}") && \
		kubectl --namespace vdp port-forward $$APIGATEWAY_POD_NAME 8080:$${APIGATEWAY_CONTAINER_PORT} > /dev/null 2>&1 &
	@export CONSOLE_POD_NAME=$$(kubectl get pods --namespace vdp -l "app.kubernetes.io/component=console,app.kubernetes.io/instance=vdp" -o jsonpath="{.items[0].metadata.name}") && \
		export CONSOLE_CONTAINER_PORT=$$(kubectl get pod --namespace vdp $$CONSOLE_POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}") && \
		kubectl --namespace vdp port-forward $$CONSOLE_POD_NAME 3000:$${CONSOLE_CONTAINER_PORT} > /dev/null 2>&1 &
	@docker run -it --rm -p 8080:8080 --name backend-helm-integration-test-latest instill/vdp-compose:latest /bin/bash -c " \
		cd pipeline-backend && make integration-test API_GATEWAY_HOST=host.docker.internal API_GATEWAY_PORT=8080 && cd ~- && \
		cd connector-backend && make integration-test API_GATEWAY_HOST=host.docker.internal API_GATEWAY_PORT=8080 && cd ~- && \
		cd model-backend && make integration-test API_GATEWAY_HOST=host.docker.internal API_GATEWAY_PORT=8080 && cd ~- && \
		cd mgmt-backend && make integration-test API_GATEWAY_HOST=host.docker.internal API_GATEWAY_PORT=8080 && cd ~- \
		"
	@docker run -it --rm \
		-e NEXT_PUBLIC_CONSOLE_BASE_URL=http://host.docker.internal:3000 \
		-e NEXT_PUBLIC_API_GATEWAY_BASE_URL=http://host.docker.internal:8080 \
		-e NEXT_PUBLIC_API_VERSION=v1alpha \
		-e NEXT_PUBLIC_SELF_SIGNED_CERTIFICATION=false \
		-e NEXT_PUBLIC_INSTILL_AI_USER_COOKIE_NAME=instill-ai-user \
		-e NEXT_PUBLIC_CONSOLE_EDITION=k8s-ce:test \
		-p 8080:8080 \
		-p 3000:3000 \
		--entrypoint ./entrypoint-playwright.sh \
		--name console-helm-integration-test-latest \
		instill/console-playwright:latest
	@helm uninstall vdp --namespace vdp
	@kubectl delete namespace vdp
	@pkill -f "port-forward"
	@make down
endif
ifeq ($(UNAME_S),Linux)
	@make build-latest
	@helm install vdp charts/vdp --devel --namespace vdp --create-namespace \
		--set itMode=true \
		--set edition=k8s-ce:test \
		--set apigateway.image.tag=latest \
		--set pipeline.image.tag=latest \
		--set connector.image.tag=latest \
		--set model.image.tag=latest \
		--set mgmt.image.tag=latest \
		--set controller.image.tag=latest \
		--set console.image.tag=latest \
		--set triton.nvidiaVisibleDevices=${TRITON_NVIDIA_VISIBLE_DEVICES} \
		--set apigatewayURL=http://localhost:8080 \
		--set consoleURL=http://localhost:3000 \
		--set console.serverApiGatewayBaseUrl=http://localhost:8080
	@sleep 1
	@export CONTROLLER_POD_NAME=$$(kubectl get pods --namespace vdp -l "app.kubernetes.io/component=controller,app.kubernetes.io/instance=vdp" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl wait --for=condition=Ready pod $$CONTROLLER_POD_NAME -n vdp --timeout=300s || true
	@export APIGATEWAY_POD_NAME=$$(kubectl get pods --namespace vdp -l "app.kubernetes.io/component=api-gateway,app.kubernetes.io/instance=vdp" -o jsonpath="{.items[0].metadata.name}") && \
		export APIGATEWAY_CONTAINER_PORT=$$(kubectl get pod --namespace vdp $$APIGATEWAY_POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}") && \
		kubectl --namespace vdp port-forward $$APIGATEWAY_POD_NAME 8080:$${APIGATEWAY_CONTAINER_PORT} > /dev/null 2>&1 &
	@export CONSOLE_POD_NAME=$$(kubectl get pods --namespace vdp -l "app.kubernetes.io/component=console,app.kubernetes.io/instance=vdp" -o jsonpath="{.items[0].metadata.name}") && \
		export CONSOLE_CONTAINER_PORT=$$(kubectl get pod --namespace vdp $$CONSOLE_POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}") && \
		kubectl --namespace vdp port-forward $$CONSOLE_POD_NAME 3000:$${CONSOLE_CONTAINER_PORT} > /dev/null 2>&1 &
	@docker run -it --rm --network host --name backend-helm-integration-test-latest instill/vdp-compose:latest /bin/bash -c " \
		cd pipeline-backend && make integration-test API_GATEWAY_HOST=localhost API_GATEWAY_PORT=8080 && cd ~- && \
		cd connector-backend && make integration-test API_GATEWAY_HOST=localhost API_GATEWAY_PORT=8080 && cd ~- && \
		cd model-backend && make integration-test API_GATEWAY_HOST=localhost API_GATEWAY_PORT=8080 && cd ~- && \
		cd mgmt-backend && make integration-test API_GATEWAY_HOST=localhost API_GATEWAY_PORT=8080 && cd ~- \
		"
	@docker run -it --rm \
		-e NEXT_PUBLIC_CONSOLE_BASE_URL=http://localhost:3000 \
		-e NEXT_PUBLIC_API_GATEWAY_BASE_URL=http://localhost:8080 \
		-e NEXT_PUBLIC_API_VERSION=v1alpha \
		-e NEXT_PUBLIC_SELF_SIGNED_CERTIFICATION=false \
		-e NEXT_PUBLIC_INSTILL_AI_USER_COOKIE_NAME=instill-ai-user \
		-e NEXT_PUBLIC_CONSOLE_EDITION=k8s-ce:test \
		--network host \
		--entrypoint ./entrypoint-playwright.sh \
		--name console-helm-integration-test-latest \
		instill/console-playwright:latest
	@helm uninstall vdp --namespace vdp
	@kubectl delete namespace vdp
	@pkill -f "port-forward"
	@make down
endif

.PHONY: helm-integration-test-release	
helm-integration-test-release:                       ## Run integration test on the Helm release for VDP
ifeq ($(UNAME_S),Darwin)
	@make build-release
	@helm install vdp charts/vdp --devel --namespace vdp --create-namespace \
		--set itMode=true \
		--set edition=k8s-ce:test \
		--set apigateway.image.tag=${API_GATEWAY_VERSION} \
		--set pipeline.image.tag=${PIPELINE_BACKEND_VERSION} \
		--set connector.image.tag=${CONNECTOR_BACKEND_VERSION} \
		--set model.image.tag=${MODEL_BACKEND_VERSION} \
		--set mgmt.image.tag=${MGMT_BACKEND_VERSION} \
		--set controller.image.tag=${CONTROLLER_VERSION} \
		--set console.image.tag=${CONSOLE_VERSION} \
		--set triton.nvidiaVisibleDevices=${TRITON_NVIDIA_VISIBLE_DEVICES} \
		--set apigatewayURL=http://host.docker.internal:8080 \
		--set consoleURL=http://host.docker.internal:3000 \
		--set console.serverApiGatewayBaseUrl=http://host.docker.internal:8080
	@sleep 1
	@export CONTROLLER_POD_NAME=$$(kubectl get pods --namespace vdp -l "app.kubernetes.io/component=controller,app.kubernetes.io/instance=vdp" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl wait --for=condition=Ready pod $$CONTROLLER_POD_NAME -n vdp --timeout=300s || true
	@export APIGATEWAY_POD_NAME=$$(kubectl get pods --namespace vdp -l "app.kubernetes.io/component=api-gateway,app.kubernetes.io/instance=vdp" -o jsonpath="{.items[0].metadata.name}") && \
		export APIGATEWAY_CONTAINER_PORT=$$(kubectl get pod --namespace vdp $$APIGATEWAY_POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}") && \
		kubectl --namespace vdp port-forward $$APIGATEWAY_POD_NAME 8080:$${APIGATEWAY_CONTAINER_PORT} > /dev/null 2>&1 &
	@export CONSOLE_POD_NAME=$$(kubectl get pods --namespace vdp -l "app.kubernetes.io/component=console,app.kubernetes.io/instance=vdp" -o jsonpath="{.items[0].metadata.name}") && \
		export CONSOLE_CONTAINER_PORT=$$(kubectl get pod --namespace vdp $$CONSOLE_POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}") && \
		kubectl --namespace vdp port-forward $$CONSOLE_POD_NAME 3000:$${CONSOLE_CONTAINER_PORT} > /dev/null 2>&1 &
	@docker run -it --rm -p 8080:8080 --name backend-helm-integration-test-release instill/vdp-compose:release /bin/bash -c " \
		cd pipeline-backend && make integration-test API_GATEWAY_HOST=host.docker.internal API_GATEWAY_PORT=8080 && cd ~- && \
		cd connector-backend && make integration-test API_GATEWAY_HOST=host.docker.internal API_GATEWAY_PORT=8080 && cd ~- && \
		cd model-backend && make integration-test API_GATEWAY_HOST=host.docker.internal API_GATEWAY_PORT=8080 && cd ~- && \
		cd mgmt-backend && make integration-test API_GATEWAY_HOST=host.docker.internal API_GATEWAY_PORT=8080 && cd ~- \
		"
	@docker run -it --rm \
		-e NEXT_PUBLIC_CONSOLE_BASE_URL=http://host.docker.internal:3000 \
		-e NEXT_PUBLIC_API_GATEWAY_BASE_URL=http://host.docker.internal:8080 \
		-e NEXT_PUBLIC_API_VERSION=v1alpha \
		-e NEXT_PUBLIC_SELF_SIGNED_CERTIFICATION=false \
		-e NEXT_PUBLIC_INSTILL_AI_USER_COOKIE_NAME=instill-ai-user \
		-e NEXT_PUBLIC_CONSOLE_EDITION=k8s-ce:test \
		-p 8080:8080 \
		-p 3000:3000 \
		--entrypoint ./entrypoint-playwright.sh \
		--name console-helm-integration-test-release \
		instill/console-playwright:${CONSOLE_VERSION}
	@helm uninstall vdp --namespace vdp
	@kubectl delete namespace vdp
	@pkill -f "port-forward"
	@make down
endif
ifeq ($(UNAME_S),Linux)
	@make build-release
	@helm install vdp charts/vdp --devel --namespace vdp --create-namespace \
		--set itMode=true \
		--set edition=k8s-ce:test \
		--set apigateway.image.tag=${API_GATEWAY_VERSION} \
		--set pipeline.image.tag=${PIPELINE_BACKEND_VERSION} \
		--set connector.image.tag=${CONNECTOR_BACKEND_VERSION} \
		--set model.image.tag=${MODEL_BACKEND_VERSION} \
		--set mgmt.image.tag=${MGMT_BACKEND_VERSION} \
		--set controller.image.tag=${CONTROLLER_VERSION} \
		--set console.image.tag=${CONSOLE_VERSION} \
		--set triton.nvidiaVisibleDevices=${TRITON_NVIDIA_VISIBLE_DEVICES} \
		--set apigatewayURL=http://localhost:8080 \
		--set consoleURL=http://localhost:3000 \
		--set console.serverApiGatewayBaseUrl=http://localhost:8080
	@sleep 1
	@export CONTROLLER_POD_NAME=$$(kubectl get pods --namespace vdp -l "app.kubernetes.io/component=controller,app.kubernetes.io/instance=vdp" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl wait --for=condition=Ready pod $$CONTROLLER_POD_NAME -n vdp --timeout=300s || true
	@export APIGATEWAY_POD_NAME=$$(kubectl get pods --namespace vdp -l "app.kubernetes.io/component=api-gateway,app.kubernetes.io/instance=vdp" -o jsonpath="{.items[0].metadata.name}") && \
		export APIGATEWAY_CONTAINER_PORT=$$(kubectl get pod --namespace vdp $$APIGATEWAY_POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}") && \
		kubectl --namespace vdp port-forward $$APIGATEWAY_POD_NAME 8080:$${APIGATEWAY_CONTAINER_PORT} > /dev/null 2>&1 &
	@export CONSOLE_POD_NAME=$$(kubectl get pods --namespace vdp -l "app.kubernetes.io/component=console,app.kubernetes.io/instance=vdp" -o jsonpath="{.items[0].metadata.name}") && \
		export CONSOLE_CONTAINER_PORT=$$(kubectl get pod --namespace vdp $$CONSOLE_POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}") && \
		kubectl --namespace vdp port-forward $$CONSOLE_POD_NAME 3000:$${CONSOLE_CONTAINER_PORT} > /dev/null 2>&1 &
	@docker run -it --rm --network host --name backend-helm-integration-test-release instill/vdp-compose:release /bin/bash -c " \
		cd pipeline-backend && make integration-test API_GATEWAY_HOST=localhost API_GATEWAY_PORT=8080 && cd ~- && \
		cd connector-backend && make integration-test API_GATEWAY_HOST=localhost API_GATEWAY_PORT=8080 && cd ~- && \
		cd model-backend && make integration-test API_GATEWAY_HOST=localhost API_GATEWAY_PORT=8080 && cd ~- && \
		cd mgmt-backend && make integration-test API_GATEWAY_HOST=localhost API_GATEWAY_PORT=8080 && cd ~- \
		"
	@docker run -it --rm \
		-e NEXT_PUBLIC_CONSOLE_BASE_URL=http://localhost:3000 \
		-e NEXT_PUBLIC_API_GATEWAY_BASE_URL=http://localhost:8080 \
		-e NEXT_PUBLIC_API_VERSION=v1alpha \
		-e NEXT_PUBLIC_SELF_SIGNED_CERTIFICATION=false \
		-e NEXT_PUBLIC_INSTILL_AI_USER_COOKIE_NAME=instill-ai-user \
		-e NEXT_PUBLIC_CONSOLE_EDITION=k8s-ce:test \
		--network host \
		--entrypoint ./entrypoint-playwright.sh \
		--name console-helm-integration-test-release \
		instill/console-playwright:${CONSOLE_VERSION}
	@helm uninstall vdp --namespace vdp
	@kubectl delete namespace vdp
	@pkill -f "port-forward"
	@make down
endif

.PHONY: help
help:       	## Show this help
	@echo "\nMake Application with Docker Compose"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
