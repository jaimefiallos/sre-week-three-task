#!/bin/bash

# Name of the namespace
NAMESPACE="sre"

# Name of the deployment
DEPLOYMENT="swype-app"

# Maximum number of restarts before scaling down
MAX_RESTARTS=4

while true; do
  # Get the number of restarts of the pod
  RESTARTS=$(kubectl get pods -n ${NAMESPACE} -l app=${DEPLOYMENT} -o jsonpath="{.items[0].status.containerStatuses[0].restartCount}")

  # Check if RESTARTS is null or empty
  if [ -z "$RESTARTS" ]; then
    echo "Failed to fetch restarts or no pods found. Checking again..."
    sleep 60
    continue
  fi

  echo "Current number of restarts: ${RESTARTS}"

  # If the number of restarts is greater than the maximum allowed, scale down the deployment
  if (( RESTARTS > MAX_RESTARTS )); then
    echo "Maximum number of restarts exceeded. Scaling down the deployment..."
    kubectl scale --replicas=0 deployment/${DEPLOYMENT} -n ${NAMESPACE}
    break
  fi

  # Wait for a while before the next check
  sleep 60
done