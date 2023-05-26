#!/bin/bash

set -e

# Retrieve the ID from the bucket created during setup
BUCKET_ID=$(influx bucket list | grep "$DOCKER_INFLUXDB_INIT_BUCKET" | awk '{print $1}')

influx v1 auth create \
  --username ${DOCKER_INFLUXDB_INIT_USERNAME} \
  --password ${DOCKER_INFLUXDB_INIT_PASSWORD} \
  --write-bucket ${BUCKET_ID} \
  --org ${DOCKER_INFLUXDB_INIT_ORG}
