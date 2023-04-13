#!/bin/bash
echo "Installing prerequisites for web-app"
echo "Running commands to install Docker"

udo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

apt-cache policy docker-ce

sudo apt install docker-ce -y

sudo systemctl status docker

echo "docker login"

sudo docker login -u kodela.akhil@gmail.com anthonydevops.jfrog.io -p cmVmdGtuOjAxOjE3MTI0MzY5MTg6TUI3eEdDRGV1bzViNkc0TXVmR3d0aDRFRHBz

sudo docker images

echo "installing kubectl"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

kubectl --version

echo "installing minikube"


curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

sudo install minikube-linux-amd64 /usr/local/bin/minikube

sudo minikube start --force

sudo minikube status

echo "installing helm"

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "installing istio -------------"

curl -L https://istio.io/downloadIstio | sh -

export PATH="$PATH:/home/ubuntu/istio-1.17.2/bin"

istioctl install --set profile=demo -y

kubectl label namespace default istio-injection=enabled

echo "deploying application"

kubectl apply -f istio-1.17.2/samples/bookinfo/platform/kube/bookinfo.yaml

sleep 60

kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"

kubectl apply -f istio-1.17.2/samples/bookinfo/networking/bookinfo-gateway.yaml

istioctl analyze

echo "prometheus scraping"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && helm repo update && helm install ksm prometheus-community/kube-state-metrics --set image.tag=v2.8.2 -n default


helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && helm repo update && helm install nodeexporter prometheus-community/prometheus-node-exporter -n default

echo "install jenkins"

helm repo add jenkins https://charts.jenkins.io
helm repo update

helm upgrade --install myjenkins jenkins/jenkins

kubectl exec --namespace default -it svc/myjenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo


