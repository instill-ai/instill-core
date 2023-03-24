.DEFAULT_GOAL:=help

#============================================================================

# load environment variables
include .env
export

TRITON_CONDA_ENV_PLATFORM := cpu
ifeq ($(shell nvidia-smi 2>/dev/null 1>&2; echo $$?),0)
	TRITONSERVER_RUNTIME := nvidia
	TRITON_CONDA_ENV_PLATFORM := gpu
endif

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
	@docker rm -f vdp-build >/dev/null 2>&1
	@docker rm -f backend-integration-test >/dev/null 2>&1
	@docker rm -f console-integration-test >/dev/null 2>&1
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
build:							## Build the latest images
	@docker build --progress plain \
		--build-arg UBUNTU_VERSION=${UBUNTU_VERSION} \
		--build-arg GOLANG_VERSION=${GOLANG_VERSION} \
		--build-arg K6_VERSION=${K6_VERSION} \
		--build-arg CACHE_DATE="$(shell date)" \
		--target latest \
		-t instill/vdp-build:test .
	@docker run -it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${PWD}/.env:/vdp/.env \
		-v ${PWD}/docker-compose.build.yml:/vdp/docker-compose.build.yml \
		--name vdp-build \
		instill/vdp-build:test /bin/bash -c " \
			docker compose -f docker-compose.build.yml build --progress plain \
		"

.PHONY: doc
doc:						## Run Redoc for OpenAPI spec at http://localhost:3001
	@docker compose up -d redoc_openapi

.PHONY: integration-test
integration-test:			## Run integration test
	@make build
	@COMPOSE_PROFILES=all EDITION=local-ce:test ITMODE=true CONSOLE_BASE_URL_HOST=console CONSOLE_BASE_API_GATEWAY_URL_HOST=api-gateway \
		docker compose -f docker-compose.yml -f docker-compose.latest.yml up -d --quiet-pull
	@COMPOSE_PROFILES=all docker compose -f docker-compose.yml -f docker-compose.latest.yml rm -f
	@docker run -it --rm \
		--network instill-network \
		--name backend-integration-test instill/vdp-build:test /bin/bash -c " \
			cd pipeline-backend && make integration-test MODE=api-gateway && cd ~- && \
			cd connector-backend && make integration-test MODE=api-gateway && cd ~- && \
			cd model-backend && make integration-test MODE=api-gateway && cd ~- && \
			cd mgmt-backend && make integration-test MODE=api-gateway && cd ~- \
		"
	@docker run -it --rm \
		-e NEXT_PUBLIC_CONSOLE_BASE_URL=http://console:3000 \
		-e NEXT_PUBLIC_API_GATEWAY_BASE_URL=http://api-gateway:8080 \
		-e NEXT_PUBLIC_API_VERSION=v1alpha \
		-e NEXT_PUBLIC_SELF_SIGNED_CERTIFICATION=false \
		-e NEXT_PUBLIC_INSTILL_AI_USER_COOKIE_NAME=instill-ai-user \
		--network instill-network \
		--entrypoint ./entrypoint-playwright.sh \
		--name console-integration-test instill/console-playwright
	@make down

.PHONY: help
help:       	## Show this help
	@echo "\nMake Application with Docker Compose"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
