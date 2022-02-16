.DEFAULT_GOAL:=help

INSTILL_SERVICES := vdp pipeline_backend_migrate pipeline_backend model_backend_migrate model_backend
3RD_PARTY_SERVICES := triton_server pg_sql cassandra temporal temporal_admin_tools temporal_web redis
ALL_SERVICES := ${INSTILL_SERVICES} ${3RD_PARTY_SERVICES}

#============================================================================

# load environment variables for local development
include .env
export

#============================================================================

all:			## Build and launch all services
	@docker-compose up -d
.PHONY: all

logs:			## Tail all logs with -n 10.
	@docker-compose logs --follow --tail=10
.PHONY: logs

pull:			## Pull all necessary images
	@docker-compose pull
.PHONY: pull

stop:			## Stop all components.
	@docker-compose stop ${ALL_SERVICES}
.PHONY: stop

start:			## Start all stopped components.
	@docker-compose start ${ALL_SERVICES}
.PHONY: start

restart:		## Restart all components.
	@docker-compose restart ${ALL_SERVICES}
.PHONY: restart

rm:				## Remove all stopped components containers.
	@docker-compose rm -f ${ALL_SERVICES}
.PHONY: rm

down:			## Down all components.
	@docker-compose down
.PHONY: down

images:			## List all images of components.
	@docker-compose images ${ALL_SERVICES}
.PHONY: images

ps:				## List all component containers.
	@docker-compose ps ${ALL_SERVICES}
.PHONY: ps

prune:			## Remove all containers and delete volume
	@make down
	@docker volume prune -f
	@rm -rf model-backend-data && rm -rf pg-sql
.PHONY: prune

build:			## Build local docker image
	@DOCKER_BUILDKIT=1 docker build -t instill/vdp:latest .
.PHONY: docker

help:       	## Show this help.
	@echo "\nMake Application using Docker-Compose files."
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

test:
	@go version
	@go install go.k6.io/xk6/cmd/xk6@latest
	@xk6 build --with github.com/szkiba/xk6-jose@latest
	# @TEST_FOLDER_ABS_PATH=${PWD}/tests ./k6 run tests/mgmt-backend.js --no-usage-report
	# @TEST_FOLDER_ABS_PATH=${PWD}/tests ./k6 run tests/pipeline-backend.js --no-usage-report
	@TEST_FOLDER_ABS_PATH=${PWD}/tests ./k6 run tests/pipeline-backend-grpc.js --no-usage-report
	# @TEST_FOLDER_ABS_PATH=${PWD}/tests ./k6 run tests/model-backend.js --no-usage-report
	@rm k6
.PHONY: test
