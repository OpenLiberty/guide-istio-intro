#!/bin/bash
set -euxo pipefail

##############################################################################
##
##  Travis CI test script
##
##############################################################################

# Deploy

mvn -q clean package

docker pull openliberty/open-liberty:kernel-java8-openj9-ubi
docker build -t system:2.0-SNAPSHOT .

kubectl apply -f ../scripts/system.yaml

sleep 120

kubectl get pods

echo `minikube ip`

curl http://`minikube ip`:31000/system/properties -I

# Run tests

mvn failsafe:integration-test -Ddockerfile.skip=true -Dcluster.ip=`minikube ip` -Dport=31000
mvn failsafe:verify

# Print logs

POD_NAME=$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep system)

kubectl logs $POD_NAME
