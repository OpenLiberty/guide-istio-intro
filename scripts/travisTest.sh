#!/bin/bash

##############################################################################
##
##  Travis CI test script
##
##############################################################################

# Deploy

printf "\nmvn -q clean package\n"
mvn -q clean package

printf "\nkubectl apply -f ../scripts/hello.yaml\n"
kubectl apply -f ../scripts/hello.yaml

printf "\nsleep 120\n"
sleep 120

printf "\nkubectl get pods\n"
kubectl get pods

printf "\nminikube ip\n"
echo `minikube ip`

printf "\ncurl http://`minikube ip`:31000/hello\n"
curl http://`minikube ip`:31000/hello

# Run tests

printf "\nmvn verify -Ddockerfile.skip=true -Dcluster.ip=`minikube ip` -Dport=31000\n"
mvn verify -Ddockerfile.skip=true -Dcluster.ip=`minikube ip` -Dport=31000

# Print logs

POD_NAME=$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep hello)

printf "\nkubectl logs $POD_NAME hello-container\n"
kubectl logs $POD_NAME
