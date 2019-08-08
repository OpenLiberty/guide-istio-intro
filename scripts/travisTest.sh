#!/bin/bash
set -euxo pipefail

##############################################################################
##
##  Travis CI test script
##
##############################################################################

# Deploy

mvn -q clean package

docker pull open-liberty
docker build -t system:2.0-SNAPSHOT .

kubectl apply -f ../scripts/system.yaml

sleep 120

kubectl get pods

echo `minikube ip`

curl http://`minikube ip`:31000/system/properties -I

# Run tests

mvn verify -Ddockerfile.skip=true -Dcluster.ip=`minikube ip` -Dport=31000

# Print logs

POD_NAME=$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep system)

kubectl logs $POD_NAME
