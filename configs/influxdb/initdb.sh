#!/bin/bash

set -e

# Retrieve the ID from the bucket created during setup
BUCKET_ID=$(influx bucket list | grep "$DOCKER_INFLUXDB_INIT_BUCKET" | awk '{print $1}')

influx v1 auth create \
  --username ${DOCKER_INFLUXDB_INIT_USERNAME} \
  --password ${DOCKER_INFLUXDB_INIT_PASSWORD} \
  --write-bucket ${BUCKET_ID} \
  --org ${DOCKER_INFLUXDB_INIT_ORG}

influx bucket create \
  --name ${DOCKER_INFLUXDB_BUCKET_VDP} \
  --org ${DOCKER_INFLUXDB_INIT_ORG} \
  --token ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} \
  --retention ${DOCKER_INFLUXDB_INIT_RETENTION}
