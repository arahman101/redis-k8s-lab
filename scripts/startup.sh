#!/bin/bash

<<<<<<< HEAD
echo "Applying Redis configMap..."
=======
echo "Applying Redis ConfigMap..."
>>>>>>> 8d74be2 (commit 2)
kubectl apply -f ../k8s/redis-configmap.yaml

echo "Applying Redis Secret..."
kubectl apply -f ../k8s/redis-secret.yaml

echo "Applying Redis PVC..."
kubectl apply -f ../k8s/redis-pvc.yaml

echo "Deploying Redis..."
kubectl apply -f ../k8s/redis-deployment.yaml

echo "Creating Redis Service..."
kubectl apply -f ../k8s/redis-service.yaml

echo "Deploying Python API..."
kubectl apply -f ../k8s/deployment.yaml

echo "Creating Python API Service..."
kubectl apply -f ../k8s/service.yaml

<<<<<<< HEAD
echo "All resources applied successfully!"
=======
echo "All resources applied successfully!"
>>>>>>> 8d74be2 (commit 2)
