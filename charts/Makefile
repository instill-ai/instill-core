.DEFAULT_GOAL:=help

INSTILL_SERVICES := mgmt-backend model-backend pipeline-backend connector-backend api-gateway console
3RD_PARTY_SERVICES := pg-sql temporal redis triton-backend
ALL_SERVICES := ${INSTILL_SERVICES} ${3RD_PARTY_SERVICES}

#============================================================================

# load environment variables
include ../.env
export

MINIKUBE_BIN := $(if $(filter arm64,$(shell uname -m)),minikube-darwin-arm64,minikube-linux-amd64)
KIND_BIN := $(if $(filter arm64,$(shell uname -m)),kind-darwin-arm64,kind-linux-amd64)

TRITONSERVER_IMAGE_TAG := $(if $(filter arm64,$(shell uname -m)),instill/tritonserver:${TRITON_SERVER_VERSION}-py3-cpu-arm64,nvcr.io/nvidia/tritonserver:${TRITON_SERVER_VERSION}-py3)
TRITONCONDAENV_IMAGE_TAG := $(if $(filter arm64,$(shell uname -m)),instill/triton-conda-env:${TRITON_CONDA_ENV_VERSION}-m1,instill/triton-conda-env:${TRITON_CONDA_ENV_VERSION}-cpu)
REDIS_IMAGE_TAG := $(if $(filter arm64,$(shell uname -m)),arm64v8/redis:${REDIS_VERSION}-alpine,amd64/redis:${REDIS_VERSION}-alpine)

TEMPORAL_HELM_VERSION=v1.18.0
TEMPORAL_TOOL_VERSION=v1.18.4

NVIDIA_SMI := $(shell nvidia-smi 2>/dev/null 1>&2; echo $$?)
ifeq ($(NVIDIA_SMI),0)
	TRITONSERVER_RUNTIME := nvidia
	TRITONCONDAENV_IMAGE_TAG := instill/triton-conda-env:${TRITON_CONDA_ENV_VERSION}-gpu
endif

# LOCAL_KUBERNETES := minikube
ifeq ($(kube),'')
	LOCAL_KUBERNETES="minikube"
else
	LOCAL_KUBERNETES=$(kube)
endif
#============================================================================

.PHONY: setup
setup: ## install minikube, helm, pull helm chart repositories
	@if [ "$(kube)" = "minikube" ] || [ "$(kube)" = "" ]; then\
		curl -LO https://storage.googleapis.com/minikube/releases/latest/${MINIKUBE_BIN}; \
		sudo install ${MINIKUBE_BIN} /usr/local/bin/minikube; \
	elif  [ "$(kube)" = "kind" ]; then \
		curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/${KIND_BIN}; \
		chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind; \
	else \
		echo "Not support $(kube)!"; \
    fi
	@curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh
	@rm ${MINIKUBE_BIN} ./get_helm.sh > /dev/null 2>&1 || true
	@printf "set up latest helm-temporal ${TEMPORAL_HELM_VERSION}: " && [ ! -d "helm-temporal" ] && git clone https://github.com/temporalio/helm-charts.git helm-temporal || git -C helm-temporal fetch && git -C helm-temporal reset --hard ${TEMPORAL_HELM_VERSION}
	@cd helm-temporal && helm dependency build
	@printf "set up temporal ${TEMPORAL_TOOL_VERSION}: " && [ ! -d "temporal" ] && git clone https://github.com/temporalio/temporal.git temporal || git -C temporal fetch && git -C temporal reset --hard ${TEMPORAL_TOOL_VERSION}
	@cd temporal && make temporal-sql-tool

.PHONY: start
start:
	@if [ "$(kube)" = "minikube" ] || [ "$(kube)" = "" ]; then\
		minikube start --driver=docker; \
		minikube ssh docker pull ${TRITONSERVER_IMAGE_TAG}; \
		minikube ssh docker pull ${TRITONCONDAENV_IMAGE_TAG}; \
	elif  [ "$(kube)" = "kind" ]; then \
		kind create cluster; \
	else \
		echo "Not support $(kube)!"; \
    fi


.PHONY: init
init: ## create cert, namespace, secret, sql and redis
	@./script/init.sh "${ALL_SERVICES}"

.PHONY: pull
pull: ## Pull all service images
	@docker inspect --type=image ${TRITONSERVER_IMAGE_TAG} >/dev/null 2>&1 || printf "\033[1;33mWARNING:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@cd .. && docker-compose pull

.PHONY: install
install: ## install helm chart backends
	@./script/install.sh "${INSTILL_SERVICES}"

.PHONY: uninstall
uninstall: ## uninstall helm chart backends
	@./script/uninstall.sh "${INSTILL_SERVICES}"

.PHONY: stop
stop:
	@minikube stop
:
.PHONY: destroy
destroy:
	@for ns in ${ALL_SERVICES}; do kubectl delete namespace $$ns > /dev/null 2>&1 || true; done

.PHONY: delete
delete:
	@if [ "$(kube)" = "minikube" ] || [ "$(kube)" = "" ]; then\
		minikube delete; \
	elif  [ "$(kube)" = "kind" ]; then \
		kind delete cluster; \
	else \
		echo "Not support $(kube)!"; \
    fi
	@rm -rf temporal; rm -rf helm-temporal  > /dev/null 2>&1 || true

