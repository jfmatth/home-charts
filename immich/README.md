# IMMICH photo Sharing
https://docs.immich.app/install/docker-compose


## Docker Compose / Podman
- Build VM (2x8)

### Podman + Compose
```
apt install podman podman-compose
```

### Install into /opt/immich

### Connect NFS shares
- Connect /opt/immich/library to an NFS share on JuiceFS  
- Connect /opt/immich/postgres to NFS share on JuiceFS  


## Helm Chart
Following video from this repo... https://github.com/oskariheino/raspberrypi/immich

**Requires CloudnativePG installed**

### Create namespace
```
kubectl apply -f immich-namespace.yaml
```
### PVC
```
kubectl apply -f immich-pvc.yaml
```
### Cluster
```
kubectl apply -f immich-cluster.yaml
```
### Helm chart install
```
helm install --create-namespace --namespace immich immich oci://ghcr.io/immich-app/immich-charts/immich -f immich-values.yaml
```
### Ingress (for minikube testing like the video)
```
minikube addons enable ingress
kubectl apply -f immich-ingress.yaml
```
### Minikube dashboard (to see action)
```
minikube addons enable metrics-server
minikube dashboard
```