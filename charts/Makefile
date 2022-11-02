.DEFAULT_GOAL:=help

INSTILL_SERVICES := mgmt-backend model-backend pipeline-backend connector-backend
3RD_PARTY_SERVICES := pg-sql temporal redis triton-backend
ALL_SERVICES := ${INSTILL_SERVICES} ${3RD_PARTY_SERVICES}

#============================================================================

# load environment variables
MINIKUBE_BIN := $(if $(filter arm64,$(shell uname -m)),minikube-darwin-amd64,minikube-linux-amd64)
DB_PASSWORD := $(shell bash -c 'echo $$RANDOM')
#============================================================================

.PHONY: setup
setup: ## install minikube, helm, pull helm chart repositories
	@curl -LO https://storage.googleapis.com/minikube/releases/latest/${MINIKUBE_BIN}
	@sudo install ${MINIKUBE_BIN} /usr/local/bin/minikube
	@curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh
	@rm ${MINIKUBE_BIN} ./get_helm.sh
# 	@printf "set up latest helm-pipeline-backend-cloud: " && [ ! -d "dev/helm-pipeline-backend-cloud" ] && git clone https://github.com/instill-ai/helm-pipeline-backend-cloud.git dev/helm-pipeline-backend-cloud || git -C dev/helm-pipeline-backend-cloud fetch && git -C dev/helm-pipeline-backend-cloud reset --hard origin/update-new-pipeline-backend-version
# 	@printf "set up latest helm-connector-backend-cloud: " && [ ! -d "dev/helm-connector-backend-cloud" ] && git clone https://github.com/instill-ai/helm-connector-backend-cloud.git dev/helm-connector-backend-cloud || git -C dev/helm-connector-backend-cloud fetch && git -C dev/helm-connector-backend-cloud reset --hard origin/main
# 	@printf "set up latest helm-model-backend-cloud: " && [ ! -d "dev/helm-model-backend-cloud" ] && git clone https://github.com/instill-ai/helm-model-backend-cloud.git dev/helm-model-backend-cloud || git -C dev/helm-model-backend-cloud fetch && git -C dev/helm-model-backend-cloud reset --hard origin/update-new-model-backend-version
# 	@printf "set up latest helm-mgmt-backend-cloud: " && [ ! -d "dev/helm-mgmt-backend-cloud" ] && git clone https://github.com/instill-ai/helm-mgmt-backend-cloud.git dev/helm-mgmt-backend-cloud || git -C dev/helm-mgmt-backend-cloud fetch && git -C dev/helm-mgmt-backend-cloud reset --hard origin/update-new-mgmt-backend-version
# 	@printf "set up latest helm-triton-backend: " && [ ! -d "dev/helm-triton-backend" ] && git clone https://github.com/instill-ai/helm-triton-backend.git dev/helm-triton-backend || git -C dev/helm-triton-backend fetch && git -C dev/helm-triton-backend reset --hard origin/update-new-triton-backend-version

.PHONY: start
start:
	@minikube start

.PHONY: init
init: ## create cert, namespace, secret, sql and redis
	@kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.yaml
	@kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.crds.yaml
	@for ns in ${ALL_SERVICES}; do kubectl create namespace $$ns > /dev/null 2>&1 || true; done
	@for ns in ${ALL_SERVICES}; do kubectl create secret generic db-user-pass --from-literal=username=postgres --from-literal=password=${DB_PASSWORD} -n $$ns > /dev/null 2>&1 || true; done
	@helm repo add pg-sql https://charts.bitnami.com/bitnami
	@helm install pg-sql pg-sql/postgresql -n pg-sql --create-namespace --set global.postgresql.auth.postgresPassword=${DB_PASSWORD}
	@helm install redis redis/redis -n redis --create-namespace --set auth.enabled=false

.PHONY: install
install: ## install helm chart backends
	@cd helm-triton-backend/triton-backend && helm install -n triton-backend triton-backend . > /dev/null 2>&1 || true
	@cd helm-temporal-cloud/temporal && helm install -n temporal temporal . > /dev/null 2>&1 || true
	@for srv in ${INSTILL_SERVICES}; do cd helm-$$srv-cloud/$$srv && helm install -n $$srv $$srv . > /dev/null 2>&1 || true && cd ../.. ; done

.PHONY: uninstall
uninstall: ## uninstall helm chart backends
	@cd helm-triton-backend/triton-backend && helm uninstall -n triton-backend triton-backend > /dev/null 2>&1 || true
	@cd helm-temporal-cloud/temporal && helm uninstall -n temporal temporal > /dev/null 2>&1 || true
	@for srv in ${INSTILL_SERVICES}; do cd helm-$$srv-cloud/$$srv && helm uninstall -n $$srv $$srv > /dev/null 2>&1 || true && cd ../.. ; done

.PHONY: stop
stop:
	@minikube stop

.PHONY: delete
delete:
	@for ns in ${ALL_SERVICES}; do kubectl delete namespace $$ns > /dev/null 2>&1 || true; done
# 	@minikube delete
