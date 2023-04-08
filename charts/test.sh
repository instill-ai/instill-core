#!/bin/bash

namespace="vdp"

helm install vdp "$PWD"/charts/vdp --devel --namespace $namespace --create-namespace \
  --set enableITMode=true \
  --set apigateway.image.tag=latest \
  --set pipeline.image.tag=latest \
  --set connector.image.tag=latest \
  --set model.image.tag=latest \
  --set mgmt.image.tag=latest \
  --set controller.image.tag=latest \
  --set console.image.tag=latest

kubectl wait --for=condition=Ready pod --all -n $namespace --timeout=300s

APIGATEWAY_POD_NAME=$(kubectl get pods --namespace vdp -l "app.kubernetes.io/component=api-gateway,app.kubernetes.io/instance=vdp" -o jsonpath="{.items[0].metadata.name}")
APIGATEWAY_CONTAINER_PORT=$(kubectl get pod --namespace vdp "$APIGATEWAY_POD_NAME" -o jsonpath="{.spec.containers[0].ports[0].containerPort}")

echo " "

if nc -zv localhost 3000 &>/dev/null; then
  echo -e "WARN: 3000 port is already in use.\n"
else
  echo -e "3000 port is ready to use.\n"
fi

if nc -zv localhost 8080 &>/dev/null; then
  echo -e "WARN: 8080 port is already in use.\n"
else
  echo -e "8080 port is ready to use.\n"
fi

kubectl --namespace vdp port-forward "$APIGATEWAY_POD_NAME" 8080:"$APIGATEWAY_CONTAINER_PORT" &

pod_list=$(kubectl get pods -n $namespace --no-headers=true | awk '{print $1}')

for pod_name in $pod_list; do
  pod_status=$(kubectl get pod "$pod_name" -n $namespace | grep Running | awk -F " " '{print $3}')

  if [[ "$pod_status" != "Running" ]]; then
    echo "Error: $pod_name pod is not running."
  fi
done

echo -e "All remaining pods are running.\n"

for pod_name in $pod_list; do
  pod_status=$(kubectl get pod "$pod_name" -n $namespace | grep Running | awk -F " " '{print $3}')

  if [[ "$pod_status" != "Running" ]]; then
    echo -e "Error: $pod_name pod is not running.\n"
  fi
done

if [ "$(curl -L http://localhost:8080/__health -o /dev/null -w '%{http_code}\n' -s)" -eq "200" ]; then echo "api-gateway OK"; fi

# wait for the conroller pod again in case if it has crashed and is still reconciling.
pod_controller=$(kubectl get po -n vdp --no-headers=true | awk '{print $1}' | grep vdp-controller)
kubectl wait --for=condition=Ready pod "$pod_controller" -n $namespace --timeout=300s
