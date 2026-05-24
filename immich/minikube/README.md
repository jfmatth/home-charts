# Minikube / Podman

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


### Minikube - Ingress (for minikube testing like the video)
```
minikube addons enable ingress
kubectl apply -f immich-mk-ingress.yaml
```
### Minikube dashboard (to see action)
```
minikube addons enable metrics-server
minikube dashboard
```