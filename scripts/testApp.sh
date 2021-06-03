#!/bin/bash
set -euxo pipefail

# Set up
../scripts/startMinikube.sh
../scripts/installIstio.sh

# Deploy

mvn -q clean package

docker pull openliberty/open-liberty:full-java11-openj9-ubi
docker build -t system:2.0-SNAPSHOT .

kubectl apply -f system.yaml
kubectl apply -f traffic.yaml

kubectl set image deployment/system-deployment-blue system-container=system:2.0-SNAPSHOT
kubectl set image deployment/system-deployment-green system-container=system:2.0-SNAPSHOT

sleep 120

kubectl get deployments

kubectl get pods

export INGRESS_PORT
INGRESS_PORT="$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')"

echo "$(minikube ip)":"$INGRESS_PORT"

curl -H "Host:example.com" -I http://"$(minikube ip)":"$INGRESS_PORT"/system/properties

# Run tests

mvn test-compile
mvn failsafe:integration-test -Ddockerfile.skip=true -Dcluster.ip="$(minikube ip)" -Dport="$INGRESS_PORT"
mvn failsafe:verify

# Print logs

PODS=$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{","}')
IFS=',' read -r -a POD_NAMES <<< "$PODS"
for pod in "${POD_NAMES[@]}"; do
    kubectl logs "$pod" --all-containers=true
done

#POD_NAMES=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep system)
#read -r -d '' -a arr <<<"${POD_NAMES}"
#for (( i=0; i<${#arr[@]}; i++ )); do
#    kubectl logs "${arr[$i]}" --all-containers=true
#done

# Tear down

../scripts/stopMinikube.sh
