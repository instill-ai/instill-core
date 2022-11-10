.DEFAULT_GOAL:=help

INSTILL_SERVICES := mgmt-backend model-backend pipeline-backend connector-backend api-gateway
3RD_PARTY_SERVICES := pg-sql temporal redis triton-backend
ALL_SERVICES := ${INSTILL_SERVICES} ${3RD_PARTY_SERVICES}

#============================================================================

# load environment variables
include ../.env
export

MINIKUBE_BIN := $(if $(filter arm64,$(shell uname -m)),minikube-darwin-arm64,minikube-linux-amd64)
DB_PASSWORD=123456

TRITON_SERVER_VERSION=22.05
TRITON_CONDA_ENV_VERSION=0.2.6-alpha
TRITONSERVER_IMAGE_TAG := $(if $(filter arm64,$(shell uname -m)),instill/tritonserver:${TRITON_SERVER_VERSION}-py3-cpu-arm64,nvcr.io/nvidia/tritonserver:${TRITON_SERVER_VERSION}-py3)
TRITONCONDAENV_IMAGE_TAG := $(if $(filter arm64,$(shell uname -m)),instill/triton-conda-env:${TRITON_CONDA_ENV_VERSION}-m1,instill/triton-conda-env:${TRITON_CONDA_ENV_VERSION}-cpu)
REDIS_IMAGE_TAG := $(if $(filter arm64,$(shell uname -m)),arm64v8/redis:${REDIS_VERSION}-alpine,amd64/redis:${REDIS_VERSION}-alpine)

TEMPORAL_DB=temporal
VISIBILITY_DB=temporal_visibility

NVIDIA_SMI := $(shell nvidia-smi 2>/dev/null 1>&2; echo $$?)
ifeq ($(NVIDIA_SMI),0)
	TRITONSERVER_RUNTIME := nvidia
	TRITONCONDAENV_IMAGE_TAG := instill/triton-conda-env:${TRITON_CONDA_ENV_VERSION}-gpu
endif

#============================================================================

.PHONY: setup
setup: ## install minikube, helm, pull helm chart repositories
	@curl -LO https://storage.googleapis.com/minikube/releases/latest/${MINIKUBE_BIN}
	@sudo install ${MINIKUBE_BIN} /usr/local/bin/minikube
	@curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh
	@rm ${MINIKUBE_BIN} ./get_helm.sh
	@printf "set up latest helm-temporal v1.18.0: " && [ ! -d "helm-temporal" ] && git clone https://github.com/temporalio/helm-charts.git helm-temporal || git -C helm-temporal fetch && git -C helm-temporal reset --hard v1.18.0
	@cd helm-temporal && helm dependency build
	@printf "set up temporal v1.18.4: " && [ ! -d "temporal" ] && git clone https://github.com/temporalio/temporal.git temporal || git -C temporal fetch && git -C temporal reset --hard v1.18.4
	@cd temporal && make temporal-sql-tool

.PHONY: start
start:
	@minikube start --driver=docker
	@minikube ssh docker pull ${TRITONSERVER_IMAGE_TAG}  ## minikube limit download image timeout 2minutes, then large image should be manually connect ssh and pull
	@minikube ssh docker pull ${TRITONCONDAENV_IMAGE_TAG}
	@sudo minikube tunnel

.PHONY: init
init: ## create cert, namespace, secret, sql and redis
	@kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.yaml
	@kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.crds.yaml
	@for ns in ${ALL_SERVICES}; do kubectl create namespace $$ns > /dev/null 2>&1 || true; done
	@for ns in ${ALL_SERVICES}; do kubectl create secret generic db-user-pass --from-literal=username=postgres --from-literal=password=${DB_PASSWORD} -n $$ns > /dev/null 2>&1 || true; done
	@helm repo add redis https://charts.bitnami.com/bitnami
	@helm install redis redis/redis -n redis --create-namespace --set auth.enabled=false > /dev/null 2>&1 || true
	@helm repo add pg-sql https://charts.bitnami.com/bitnami
	@helm install pg-sql pg-sql/postgresql -n pg-sql --create-namespace --set global.postgresql.auth.postgresPassword=${DB_PASSWORD} > /dev/null 2>&1 || true && \
	sleep 10 && kubectl wait --for=condition=ready pod pg-sql-postgresql-0 -n pg-sql && sleep 1 && \
	kill $(shell lsof -t -i:5432) > /dev/null 2>&1 || true && kubectl port-forward --namespace pg-sql svc/pg-sql-postgresql 5432:5432 & \
	sleep 60 && cd temporal && export SQL_PLUGIN=postgres && export SQL_HOST=127.0.0.1 && export SQL_PORT=5432 && export SQL_USER=postgres && export SQL_PASSWORD=${DB_PASSWORD} && export SQL_DATABASE=temporal && export TEMPORAL_DB=temporal && make install-schema-postgresql && \
	cd ../helm-temporal && helm install -n temporal temporal -f values/values.postgresql.yaml --set server.replicaCount=1 --set cassandra.enabled=false --set prometheus.enabled=false --set grafana.enabled=false --set elasticsearch.enabled=false --set server.config.persistence.default.sql.user=postgres --set server.config.persistence.default.sql.password=${DB_PASSWORD} --set server.config.persistence.default.sql.host=pg-sql-postgresql.pg-sql  --set server.config.persistence.visibility.sql.user=postgres --set server.config.persistence.visibility.sql.password=${DB_PASSWORD} --set server.config.persistence.visibility.sql.host=pg-sql-postgresql.pg-sql . > /dev/null 2>&1 || true &&\
	sleep 30 && kubectl exec -it services/temporal-admintools -n temporal -- /bin/bash -c "tctl --ns default namespace register" > /dev/null 2>&1 || true

.PHONY: install
install: ## install helm chart backends
	@cd helm-triton-backend/triton-backend && helm install -n triton-backend triton-backend . --set arch=$(shell uname -m) > /dev/null 2>&1 || true
	@for srv in ${INSTILL_SERVICES}; do cd helm-$$srv/$$srv || cd helm-$$srv/$$srv && helm install -n $$srv $$srv . > /dev/null 2>&1 || true && cd ../.. ; done

.PHONY: uninstall
uninstall: ## uninstall helm chart backends
	@cd helm-triton-backend/triton-backend && helm uninstall -n triton-backend triton-backend > /dev/null 2>&1 || true
	@for srv in ${INSTILL_SERVICES}; do cd helm-$$srv/$$srv || cd helm-$$srv/$$srv && helm uninstall -n $$srv $$srv > /dev/null 2>&1 || true && cd ../.. ; done

.PHONY: stop
stop:
	@minikube stop

.PHONY: destroy
destroy:
	@for ns in ${ALL_SERVICES}; do kubectl delete namespace $$ns > /dev/null 2>&1 || true; done

.PHONY: delete
delete:
	@minikube delete
	@rm -rf temporal; rm -rf helm-temporal  > /dev/null 2>&1 || true
