# IMMICH photo Sharing
https://docs.immich.app/install/docker-compose

**Requires CloudnativePG installed**

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

### Create namespace
```
kubectl apply -f immich-namespace.yaml
```


### PVC
```
kubectl apply -f immich-pvc.yaml
```
