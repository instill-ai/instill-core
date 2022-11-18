#!/bin/sh

ALL_SERVICES=$1
DB_PASSWORD="123456"
DB_PORT=5431
TEMPORAL_DB=temporal
VISIBILITY_DB=temporal_visibility

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
kubectl wait --for=condition=ready pod $(kubectl get pods -n pg-sql -o 'jsonpath={.items..metadata.name}') -n pg-sql --timeout=180s
kill -9 $(lsof -t -i:${DB_PORT}) > /dev/null 2>&1 || true && kubectl port-forward --namespace pg-sql svc/pg-sql-postgresql ${DB_PORT}:5432 > /dev/null 2>&1 &
while ! nc -z localhost ${DB_PORT}; do echo "wait for forwarding postgres db service port finish"; sleep 1; done
sleep 2; cd temporal # sleep 2 seconds to make sure forwarding port totally finished
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p ${DB_PORT} --pl postgres --db ${TEMPORAL_DB} drop -f
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p ${DB_PORT} --pl postgres --db ${TEMPORAL_DB} create
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p ${DB_PORT} --pl postgres --db ${TEMPORAL_DB} setup -v 0.0
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p ${DB_PORT} --pl postgres --db ${TEMPORAL_DB} update-schema -d ./schema/postgresql/v96/temporal/versioned
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p ${DB_PORT} --pl postgres --db ${VISIBILITY_DB} drop -f
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p ${DB_PORT} --pl postgres --db ${VISIBILITY_DB} create
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p ${DB_PORT} --pl postgres --db ${VISIBILITY_DB} setup-schema -v 0.0
./temporal-sql-tool -u postgres --pw ${DB_PASSWORD} -p ${DB_PORT} --pl postgres --db ${VISIBILITY_DB} update-schema -d ./schema/postgresql/v96/visibility/versioned
cd ..
# deploy temporal
cd helm-temporal && helm install -n temporal temporal -f values/values.postgresql.yaml --set server.replicaCount=1 --set cassandra.enabled=false --set prometheus.enabled=false --set grafana.enabled=false --set elasticsearch.enabled=false --set server.config.persistence.default.sql.user=postgres --set server.config.persistence.default.sql.password=${DB_PASSWORD} --set server.config.persistence.default.sql.host=pg-sql-postgresql.pg-sql  --set server.config.persistence.visibility.sql.user=postgres --set server.config.persistence.visibility.sql.password=${DB_PASSWORD} --set server.config.persistence.visibility.sql.host=pg-sql-postgresql.pg-sql . > /dev/null 2>&1 || true
kubectl wait --for=condition=ready pod $(kubectl get pods -n temporal -o 'jsonpath={.items..metadata.name}') -n temporal --timeout=180s
# create default namespace for temporal, helm deployment do not create default namespace
kubectl exec -it services/temporal-admintools -n temporal -- /bin/bash -c "tctl --ns default namespace register" > /dev/null 2>&1 || true