#!/bin/bash

##############################################################################
##
##  Travis CI test script
##
##############################################################################

# Deploy v1
printf "\nmvn -q package\n"
mvn -q clean package

printf "\nistioctl kube-inject -f hello.yaml | kubectl apply -f -\n"
istioctl kube-inject -f hello.yaml | kubectl apply -f -

printf "\nkubectl apply -f traffic.yaml\n"
kubectl apply -f traffic.yaml

printf "\nsleep 120\n"
sleep 120

printf "\nkubectl get pods\n"
kubectl get pods

printf "\nminikube ip\n"
echo `minikube ip`

printf "\ncurl http://`minikube ip`:31380/hello -HHost:example.com\n"
curl http://`minikube ip`:31380/hello -HHost:example.com

# Deploy v2

printf "\nmvn versions:set -DnewVersion=2.0-SNAPSHOT\n"
mvn versions:set -DnewVersion=2.0-SNAPSHOT

printf "\nmvn -q package\n"
mvn -q clean package

printf "\nkubectl set image deployment/hello-deployment-green hello-container=hello:2.0-SNAPSHOT"
kubectl set image deployment/hello-deployment-green hello-container=hello:2.0-SNAPSHOT

printf "\nkubectl apply -f ../finish/traffic.yaml\n"
kubectl apply -f ../finish/traffic.yaml

printf "\nsleep 120\n"
sleep 120

printf "\nkubectl get pods\n"
kubectl get pods

printf "\nminikube ip\n"
echo `minikube ip`

printf "\ncurl http://`minikube ip`:31380/hello -HHost:test.example.com\n"
curl http://`minikube ip`:31380/hello -HHost:test.example.com

# Run tests

cp ../finish/src/test/java/it/io/openliberty/guides/rest/EndpointTest.java src/test/java/it/io/openliberty/guides/rest/EndpointTest.java
printf "\nmvn verify -Ddockerfile.skip=true -Dcluster.ip=`minikube ip` -Dport=31380\n"
mvn verify -Ddockerfile.skip=true -Dcluster.ip=`minikube ip` -Dport=31380

# Print logs

BLUE_POD=$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep blue)
GREEN_POD=$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep green)

printf "\nkubectl logs $BLUE_POD hello-container\n"
kubectl logs $BLUE_POD hello-container

printf "\nkubectl logs $GREEN_POD hello-container\n"
kubectl logs $GREEN_POD hello-container

