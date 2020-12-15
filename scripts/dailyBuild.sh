#!/bin/bash
while getopts t:d:b:u: flag;
do
    case "${flag}" in
        t) DATE="${OPTARG}";;
        d) DRIVER="${OPTARG}";;
        b) BUILD="${OPTARG}";;
        u) DOCKER_USERNAME="${OPTARG}";;
    esac
done

echo "Testing daily build image"

sed -i "\#<artifactId>liberty-maven-plugin</artifactId>#a<configuration><install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/"$DATE"/"$DRIVER"</runtimeUrl></install></configuration>" pom.xml
cat pom.xml

sed -i "s;FROM openliberty/open-liberty:kernel-java8-openj9-ubi;FROM "$DOCKER_USERNAME"/olguides:"$BUILD";g" Dockerfile
cat Dockerfile

../scripts/testApp.sh

kubectl delete -f services.yaml
kubectl delete -f traffic.yaml
kubectl label namespace default istio-injection-
kubectl delete -f install/kubernetes/istio-demo.yaml
istioctl x uninstall --purge
eval $(minikube docker-env -u)
minikube stop
minikube delete

echo "Testing daily Docker image"

sed -i "s;FROM "$DOCKER_USERNAME"/olguides:"$BUILD;FROM openliberty/daily:latest;g" Dockerfile

cat Dockerfile

docker pull "openliberty/daily:latest"

../scripts/testApp.sh
