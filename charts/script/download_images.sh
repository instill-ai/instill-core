#!/bin/sh

INSTILL_SERVICES=$1

helm install -n triton-backend triton-backend helm-triton-backend/triton-backend --set arch=$(uname -m) > /dev/null 2>&1 || true
kubectl wait --for=condition=ready pod $(kubectl get pods -n triton-backend -o 'jsonpath={.items..metadata.name}') -n triton-backend --timeout=600s
for srv in ${INSTILL_SERVICES}; do helm install -n $srv $srv helm-$srv/$srv > /dev/null 2>&1 || true ; done
kubectl wait --for=condition=ready pod $(kubectl get pods -n api-gateway -o 'jsonpath={.items..metadata.name}') -n api-gateway --timeout=300s
kubectl port-forward -n api-gateway deployment/api-gateway 8000:8000 &
kubectl port-forward -n console deployment/console 3000:3000 &