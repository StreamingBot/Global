# Global
```
minikube start

kubectl apply -f minikube/namespace.yaml
kubectl apply -f minikube/secrets.yaml
kubectl apply -f minikube/storage.yaml
```

# Build services
```
docker build -t auth-service:latest ./Authentication/
docker build -t discord-service:latest ./Discord/
docker build -t user-service:latest ./User/
```

# Load images into Minikube
```
minikube image load auth-service:latest
minikube image load discord-service:latest
minikube image load user-service:latest
```

# Deploy services
```
kubectl apply -f minikube/services.yaml
kubectl apply -f minikube/deployments.yaml
```

# Verify and access
```
# Get Minikube IP
```minikube ip```

# Optional: Open Minikube dashboard
```minikube dashboard```

