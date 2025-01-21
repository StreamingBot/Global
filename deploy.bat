@echo off

minikube start

kubectl apply -f minikube/namespace.yaml

kubectl apply -f minikube/secrets.yaml

kubectl apply -f minikube/storage.yaml

docker build -t auth-service:latest ./Authentication/

docker build -t discord-service:latest ./Discord/

docker build -t user-service:latest ./User/

minikube image load auth-service:latest

minikube image load discord-service:latest

minikube image load user-service:latest

kubectl apply -f minikube/services.yaml

kubectl apply -f minikube/deployments.yaml

for /f "tokens=*" %%i in ('minikube ip') do set MINIKUBE_IP=%%i
echo Minikube IP: %MINIKUBE_IP%
echo Keycloak: http://%MINIKUBE_IP%:30010
echo Auth Service: http://%MINIKUBE_IP%:30001
echo Discord Service: http://%MINIKUBE_IP%:30002
echo User Service: http://%MINIKUBE_IP%:30003

:: Optional: Open dashboard
set /p DASHBOARD="Would you like to open the Minikube dashboard? (y/n) "
if /i "%DASHBOARD%"=="y" (
    CALL :print_status "Opening Minikube dashboard..."
    start minikube dashboard
)

CALL :print_status "Deployment complete!"
pause
exit /b 0 