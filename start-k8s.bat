@echo off
echo Starting Minikube...
minikube start

echo Enabling metrics-server...
minikube addons enable metrics-server

echo Waiting for metrics-server to start (30 seconds)...
timeout /t 30 /nobreak

echo Creating namespace...
kubectl create namespace streamerbot
kubectl config set-context --current --namespace=streamerbot

echo Creating persistent volumes and storage class...
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

echo Creating persistent volume claims...
kubectl apply -f k8s/volumes/keycloak-pvc.yaml
kubectl apply -f k8s/volumes/postgres-pvc.yaml
kubectl apply -f k8s/volumes/discord-postgres-pvc.yaml

echo Applying database configurations...
kubectl apply -f k8s/keycloak/postgres.yaml
kubectl apply -f k8s/discord/postgres.yaml

echo Waiting for databases to initialize (30 seconds)...
timeout /t 30 /nobreak

echo Applying Keycloak configurations...
kubectl apply -f k8s/keycloak/keycloak.yaml

echo Waiting for Keycloak to start (30 seconds)...
timeout /t 30 /nobreak

echo Applying service configurations...
kubectl apply -f k8s/auth/configmap.yaml
kubectl apply -f k8s/auth/secret.yaml
kubectl apply -f k8s/auth/deployment.yaml
kubectl apply -f k8s/auth/service.yaml

kubectl apply -f k8s/user/configmap.yaml
kubectl apply -f k8s/user/secret.yaml
kubectl apply -f k8s/user/deployment.yaml
kubectl apply -f k8s/user/service.yaml

kubectl apply -f k8s/discord/configmap.yaml
kubectl apply -f k8s/discord/secret.yaml
kubectl apply -f k8s/discord/deployment.yaml
kubectl apply -f k8s/discord/service.yaml

kubectl apply -f k8s/gateway/configmap.yaml
kubectl apply -f k8s/gateway/secret.yaml
kubectl apply -f k8s/gateway/deployment.yaml
kubectl apply -f k8s/gateway/service.yaml

echo Setting up autoscaling...
kubectl apply -f k8s/hpa-behavior.yaml

echo Waiting for services to start (30 seconds)...
timeout /t 30 /nobreak

echo Checking deployment status...
kubectl get pods
kubectl get services
kubectl get hpa

echo Setting up port forwarding for Gateway...
start cmd /k kubectl port-forward service/gateway 5000:5000

echo Setting up port forwarding for Keycloak...
start cmd /k kubectl port-forward service/keycloak 5010:5010

echo Starting Minikube dashboard...
start minikube dashboard 