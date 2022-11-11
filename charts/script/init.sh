#!/bin/sh

ALL_SERVICES=$1
DB_PASSWORD="123456"

## deploy cert
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.yaml
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.crds.yaml
# create namespaces and secrets
for ns in ${ALL_SERVICES}; do kubectl create namespace $ns > /dev/null 2>&1 || true; done
for ns in ${ALL_SERVICES}; do kubectl create secret generic db-user-pass --from-literal=username=postgres --from-literal=password=${DB_PASSWORD} -n $ns > /dev/null 2>&1 || true; done
# deploy redis
helm repo add redis https://charts.bitnami.com/bitnami
helm install redis redis/redis -n redis --create-namespace --set auth.enabled=false > /dev/null 2>&1 || true
# deploy postgres
helm repo add pg-sql https://charts.bitnami.com/bitnami
helm install pg-sql pg-sql/postgresql -n pg-sql --create-namespace --set global.postgresql.auth.postgresPassword=${DB_PASSWORD} > /dev/null 2>&1 || true
# forwarding port to migrate temporal db
kubectl wait --for=condition=ready pod $(kubectl get pods -n pg-sql -o 'jsonpath={.items..metadata.name}') -n pg-sql
kill -9 $(lsof -t -i:5431) > /dev/null 2>&1 || true && kubectl port-forward --namespace pg-sql svc/pg-sql-postgresql 5431:5432 > /dev/null 2>&1 &
while ! nc -z localhost 5431; do echo "wait for forwarding postgres db service port finish"; sleep 1; done
cd temporal
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p 5431 --pl postgres --db temporal drop -f
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p 5431 --pl postgres --db temporal create
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p 5431 --pl postgres --db temporal setup -v 0.0
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p 5431 --pl postgres --db temporal update-schema -d ./schema/postgresql/v96/temporal/versioned
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p 5431 --pl postgres --db temporal_visibility drop -f
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p 5431 --pl postgres --db temporal_visibility create
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p 5431 --pl postgres --db temporal_visibility setup-schema -v 0.0
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p 5431 --pl postgres --db temporal_visibility update-schema -d ./schema/postgresql/v96/visibility/versioned
cd ..
# deploy temporal
cd helm-temporal && helm install -n temporal temporal -f values/values.postgresql.yaml --set server.replicaCount=1 --set cassandra.enabled=false --set prometheus.enabled=false --set grafana.enabled=false --set elasticsearch.enabled=false --set server.config.persistence.default.sql.user=postgres --set server.config.persistence.default.sql.password=${DB_PASSWORD} --set server.config.persistence.default.sql.port=5431 --set server.config.persistence.default.sql.host=pg-sql-postgresql.pg-sql  --set server.config.persistence.visibility.sql.user=postgres --set server.config.persistence.visibility.sql.password=${DB_PASSWORD} --set server.config.persistence.visibility.sql.port=5431 --set server.config.persistence.visibility.sql.host=pg-sql-postgresql.pg-sql . > /dev/null 2>&1 || true
kubectl wait --for=condition=ready pod $(kubectl get pods -n temporal -o 'jsonpath={.items..metadata.name}') -n temporal
# create default namespace for temporal, helm deployment do not create default namespace
kubectl exec -it services/temporal-admintools -n temporal -- /bin/bash -c "tctl --ns default namespace register" > /dev/null 2>&1 || true