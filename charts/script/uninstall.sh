#!/bin/sh

INSTILL_SERVICES=$1

helm uninstall -n triton-backend triton-backend helm-triton-backend/triton-backend  > /dev/null 2>&1 || true
for srv in ${INSTILL_SERVICES}; do helm uninstall -n $srv $srv helm-$srv/$srv > /dev/null 2>&1 || true ; done
kill -9 $(lsof -t -i:8000) > /dev/null 2>&1 || true
kill -9 $(lsof -t -i:3000) > /dev/null 2>&1 || true