#!/bin/bash
kubectl delete -f services.yaml
kubectl delete -f traffic.yaml
kubectl label namespace default istio-injection-
istioctl x uninstall --purge

eval $(minikube docker-env -u)
minikube stop
minikube delete
