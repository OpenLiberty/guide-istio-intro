#!/bin/bash
ISTIO_LATEST=1.7.6

curl -L https://github.com/istio/istio/releases/download/$ISTIO_LATEST/istio-$ISTIO_LATEST-linux-amd64.tar.gz | tar xzvf -

cd istio-$ISTIO_LATEST

export PATH=$PWD/bin:$PATH

istioctl install --set profile=demo

echo "Installed Istio $(istioctl version)"

sleep 240

kubectl get deployments -n istio-system

kubectl label --overwrite namespace default istio-injection=enabled

cd ..
