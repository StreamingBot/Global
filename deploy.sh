#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}[+] $1${NC}"
}

# Function to print error and exit
print_error() {
    echo -e "${RED}[-] $1${NC}"
    exit 1
}

# Start Minikube
print_status "Starting Minikube..."
minikube start || print_error "Failed to start Minikube"

# Create namespace and apply initial configs
print_status "Applying initial configurations..."
kubectl apply -f minikube/namespace.yaml || print_error "Failed to create namespace"
kubectl apply -f minikube/secrets.yaml || print_error "Failed to apply secrets"
kubectl apply -f minikube/storage.yaml || print_error "Failed to apply storage configurations"

# Build Docker images
print_status "Building Docker images..."
docker build -t auth-service:latest ./Authentication/ || print_error "Failed to build auth-service"
docker build -t discord-service:latest ./Discord/ || print_error "Failed to build discord-service"
docker build -t user-service:latest ./User/ || print_error "Failed to build user-service"

# Load images into Minikube
print_status "Loading images into Minikube..."
minikube image load auth-service:latest || print_error "Failed to load auth-service image"
minikube image load discord-service:latest || print_error "Failed to load discord-service image"
minikube image load user-service:latest || print_error "Failed to load user-service image"

# Deploy services and applications
print_status "Deploying services and applications..."
kubectl apply -f minikube/services.yaml || print_error "Failed to apply services"
kubectl apply -f minikube/deployments.yaml || print_error "Failed to apply deployments"

# Get Minikube IP
print_status "Getting Minikube IP..."
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"

# Print access information
print_status "Services are accessible at:"
echo "Keycloak: http://$MINIKUBE_IP:30010"
echo "Auth Service: http://$MINIKUBE_IP:30001"
echo "Discord Service: http://$MINIKUBE_IP:30002"
echo "User Service: http://$MINIKUBE_IP:30003"

# Optional: Open dashboard
read -p "Would you like to open the Minikube dashboard? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    print_status "Opening Minikube dashboard..."
    minikube dashboard
fi

print_status "Deployment complete!" 