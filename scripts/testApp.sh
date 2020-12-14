#!/bin/bash
set -euxo pipefail

# Set up and start Minikube

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo ln -s -f $(pwd)/kubectl /usr/local/bin/kubectl
wget https://github.com/kubernetes/minikube/releases/download/v0.28.2/minikube-linux-amd64 -q -O minikube
chmod +x minikube

sudo apt-get update -y
sudo apt-get install -y conntrack
sudo apt-get install jq

sudo minikube start --vm-driver=none --bootstrapper=kubeadm

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

kubectl delete -f services.yaml
kubectl delete -f traffic.yaml
kubectl label namespace default istio-injection-
kubectl delete -f install/kubernetes/istio-demo.yaml
istioctl x uninstall --purge
eval $(minikube docker-env -u)
minikube stop
minikube delete
