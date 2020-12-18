#!/bin/bash
set -euxo pipefail

# Set up
. ../scripts/startMinikube.sh
. ../scripts/installIstio.sh

# Deploy

mvn -q clean package

docker pull openliberty/open-liberty:kernel-java8-openj9-ubi
docker build -t system:2.0-SNAPSHOT .

kubectl apply -f system.yaml
kubectl apply -f traffic.yaml

sleep 120

kubectl get deployments

kubectl get pods

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

echo $(minikube ip):$INGRESS_PORT

curl -H "Host:example.com" -I http://$(minikube ip):$INGRESS_PORT/system/properties

# Run tests

mvn test-compile
mvn failsafe:integration-test -Ddockerfile.skip=true -Dcluster.ip=`minikube ip` -Dport=$INGRESS_PORT
mvn failsafe:verify

# Print logs

POD_NAME=$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep system)

kubectl logs $POD_NAME

# Tear down

. ../scripts/stopMinikube.sh
