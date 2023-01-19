#!/bin/bash

echo -n "Deleting minikube ... "
minikube delete
echo "Done."

echo "Starting minikube"
minikube start

mkdir -p /tmp/pronosana

kubectl apply -f pronosana_configs/minikube
echo "Sleeping for 120 seconds for prometheus to come up along with thanos"
sleep 120
deployment_name=$(kubectl get pods | grep "pronosana-deployment" | cut -d " " -f1)
kubectl cp ${PWD}/tmp_data/omf_data.txt default/${deployment_name}:/home -c prometheus
kubectl exec -it ${deployment_name} -c prometheus promtool tsdb create-blocks-from openmetrics /home/omf_data.txt /prometheus

IP=$(minikube ip)
firefox -new-tab "http://${IP}:30300"
