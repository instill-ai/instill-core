.DEFAULT_GOAL:=help

INSTILL_SERVICES := model_backend_migrate model_backend pipeline_backend_migrate pipeline_backend visual_data_preparation
3RD_PARTY_SERVICES := triton_server pg_sql cassandra temporal temporal_admin_tools temporal_web redis
ALL_SERVICES := ${INSTILL_SERVICES} ${3RD_PARTY_SERVICES}

#============================================================================

# load environment variables for local development
include .env
export

#============================================================================

all:		    	## Start all components including application, monitoring and logging stacks.
	@docker-compose up -d --build
.PHONY: all

logs:			## Tail all logs with -n 10.
	@docker-compose logs --follow --tail=10
.PHONY: logs

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

ps:			## List all component containers.
	@docker-compose ps ${ALL_SERVICES}
.PHONY: ps

prune:			## Remove all containers and delete volume
	@make stop && make rm
	@docker volume prune -f
.PHONY: prune
