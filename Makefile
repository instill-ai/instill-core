.DEFAULT_GOAL:=help

INSTILL_SERVICES := mgmt_backend pipeline_backend connector_backend model_backend triton_conda_env
3RD_PARTY_SERVICES := pg_sql triton_server temporal temporal_admin_tools temporal_web redis redoc_openapi
VOLUMES := model-repository conda-pack

#============================================================================

# load environment variables for local development
include .env
export

#============================================================================

.PHONY: all
all:			## Launch all services
	@docker inspect --type=image nvcr.io/nvidia/tritonserver:${TRITONSERVER_VERSION} >/dev/null 2>&1 || printf "\033[1;33mWARNING:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@docker-compose up -d vdp ${INSTILL_SERVICES} ${3RD_PARTY_SERVICES}

.PHONY: logs
logs:			## Tail all logs with -n 10
	@docker-compose logs --follow --tail=10

.PHONY: pull
pull:			## Pull all service images
	@docker inspect --type=image nvcr.io/nvidia/tritonserver:${TRITONSERVER_VERSION} >/dev/null 2>&1 || printf "\033[1;33mWARNING:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@docker-compose pull ${INSTILL_SERVICES} ${3RD_PARTY_SERVICES}

.PHONY: stop
stop:			## Stop all components
	@docker-compose stop vdp ${INSTILL_SERVICES} ${3RD_PARTY_SERVICES}

.PHONY: start
start:			## Start all stopped services
	@docker-compose start vdp ${INSTILL_SERVICES} ${3RD_PARTY_SERVICES}

.PHONY: restart
restart:		## Restart all services
	@docker-compose restart vdp ${INSTILL_SERVICES} ${3RD_PARTY_SERVICES}

.PHONY: rm
rm:				## Remove all stopped service containers
	@docker-compose rm -f vdp ${INSTILL_SERVICES} ${3RD_PARTY_SERVICES}

.PHONY: down
down:			## Stop all services and remove all service containers and volumes
	@docker-compose down -v

.PHONY: images
images:			## List all container images
	@docker-compose images vdp ${INSTILL_SERVICES} ${3RD_PARTY_SERVICES}

.PHONY: ps
ps:				## List all service containers
	@docker-compose ps vdp ${INSTILL_SERVICES} ${3RD_PARTY_SERVICES}

.PHONY: top
top:			## Display all running service processes
	@docker-compose top vdp ${INSTILL_SERVICES} ${3RD_PARTY_SERVICES}

.PHONY: doc
doc:			## Run Redoc for OpenAPI spec at http://localhost:3000
	@docker-compose up -d redoc_openapi

.PHONY: help
help:       	## Show this help
	@echo "\nMake Application using Docker-Compose files."
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
