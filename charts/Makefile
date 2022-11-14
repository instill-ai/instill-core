.DEFAULT_GOAL:=help

INSTILL_SERVICES := mgmt-backend model-backend pipeline-backend connector-backend api-gateway
3RD_PARTY_SERVICES := pg-sql temporal redis triton-backend
ALL_SERVICES := ${INSTILL_SERVICES} ${3RD_PARTY_SERVICES}

#============================================================================

# load environment variables
include ../.env
export

MINIKUBE_BIN := $(if $(filter arm64,$(shell uname -m)),minikube-darwin-arm64,minikube-linux-amd64)

TRITONSERVER_IMAGE_TAG := $(if $(filter arm64,$(shell uname -m)),instill/tritonserver:${TRITON_SERVER_VERSION}-py3-cpu-arm64,nvcr.io/nvidia/tritonserver:${TRITON_SERVER_VERSION}-py3)
TRITONCONDAENV_IMAGE_TAG := $(if $(filter arm64,$(shell uname -m)),instill/triton-conda-env:${TRITON_CONDA_ENV_VERSION}-m1,instill/triton-conda-env:${TRITON_CONDA_ENV_VERSION}-cpu)
REDIS_IMAGE_TAG := $(if $(filter arm64,$(shell uname -m)),arm64v8/redis:${REDIS_VERSION}-alpine,amd64/redis:${REDIS_VERSION}-alpine)

TEMPORAL_HELM_VERSION=v1.18.0
TEMPORAL_VERSION=v1.18.4

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
	@printf "set up latest helm-temporal ${TEMPORAL_HELM_VERSION}: " && [ ! -d "helm-temporal" ] && git clone https://github.com/temporalio/helm-charts.git helm-temporal || git -C helm-temporal fetch && git -C helm-temporal reset --hard ${TEMPORAL_HELM_VERSION}
	@cd helm-temporal && helm dependency build
	@printf "set up temporal ${TEMPORAL_VERSION}: " && [ ! -d "temporal" ] && git clone https://github.com/temporalio/temporal.git temporal || git -C temporal fetch && git -C temporal reset --hard ${TEMPORAL_VERSION}
	@cd temporal && make temporal-sql-tool

.PHONY: start
start:
	@minikube start --driver=docker
	@minikube ssh docker pull ${TRITONSERVER_IMAGE_TAG}  ## minikube limit download image timeout 2minutes, then large image should be manually connect ssh and pull
	@minikube ssh docker pull ${TRITONCONDAENV_IMAGE_TAG}
	@sudo minikube tunnel

.PHONY: init
init: ## create cert, namespace, secret, sql and redis
	@./script/init.sh "${ALL_SERVICES}"

.PHONY: install
install: ## install helm chart backends
	@cd helm-triton-backend/triton-backend && helm install -n triton-backend triton-backend . --set arch=$(shell uname -m) > /dev/null 2>&1 || true
	@for srv in ${INSTILL_SERVICES}; do helm install -n $$srv $$srv helm-$$srv/$$srv > /dev/null 2>&1 || true ; done

.PHONY: uninstall
uninstall: ## uninstall helm chart backends
	@cd helm-triton-backend/triton-backend && helm uninstall -n triton-backend triton-backend > /dev/null 2>&1 || true
	@for srv in ${INSTILL_SERVICES}; do helm uninstall -n $$srv $$srv helm-$$srv/$$srv > /dev/null 2>&1 || true ; done

.PHONY: stop
stop:
	@minikube stop
:
.PHONY: destroy
destroy:
	@for ns in ${ALL_SERVICES}; do kubectl delete namespace $$ns > /dev/null 2>&1 || true; done

.PHONY: delete
delete:
	@minikube delete
	@rm -rf temporal; rm -rf helm-temporal  > /dev/null 2>&1 || true
