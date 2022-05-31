.DEFAULT_GOAL:=help

INSTILL_SERVICES := mgmt_backend pipeline_backend connector_backend model_backend triton_conda_env
3RD_PARTY_SERVICES := pg_sql triton_server redis redoc_openapi
TEMPORAL := temporal temporal_admin_tools temporal_ui
VOLUMES := model-repository conda-pack

#============================================================================

# load environment variables for local development
include .env
export

#============================================================================

.PHONY: all
all:			## Launch all services with their up-to-date release version
	@docker inspect --type=image nvcr.io/nvidia/tritonserver:${TRITONSERVER_VERSION} >/dev/null 2>&1 || printf "\033[1;33mWARNING:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@docker-compose up -d

.PHONY: dev
dev:			## Lunch and build all services with their dev version (i.e., main branch)
	@[ ! -d "dev/mgmt-backend" ] && git clone https://github.com/instill-ai/mgmt-backend.git dev/mgmt-backend || git -C dev/mgmt-backend pull https://github.com/instill-ai/mgmt-backend.git
	@[ ! -d "dev/pipeline-backend" ] && git clone https://github.com/instill-ai/pipeline-backend.git dev/pipeline-backend || git -C dev/pipeline-backend pull https://github.com/instill-ai/pipeline-backend.git
	@[ ! -d "dev/connector-backend" ] && git clone https://github.com/instill-ai/connector-backend.git dev/connector-backend || git -C dev/connector-backend pull https://github.com/instill-ai/connector-backend.git
	@[ ! -d "dev/model-backend" ] && git clone https://github.com/instill-ai/model-backend.git dev/model-backend || git -C dev/model-backend pull https://github.com/instill-ai/model-backend.git
	@docker-compose -f docker-compose-dev.yml build --parallel
	@docker-compose -f docker-compose-dev.yml up -d

.PHONY: temporal
temporal:		## Launch Temporal services
	@docker-compose up -d ${TEMPORAL}

.PHONY: logs
logs:			## Tail all logs with -n 10
	@docker-compose logs --follow --tail=10

.PHONY: pull
pull:			## Pull all service images
	@docker inspect --type=image nvcr.io/nvidia/tritonserver:${TRITONSERVER_VERSION} >/dev/null 2>&1 || printf "\033[1;33mWARNING:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
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

.PHONY: doc
doc:			## Run Redoc for OpenAPI spec at http://localhost:3000
	@docker-compose up -d redoc_openapi

.PHONY: help
help:       	## Show this help
	@echo "\nMake Application using Docker-Compose files."
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
