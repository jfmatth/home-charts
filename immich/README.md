# IMMICH photo Sharing
https://docs.immich.app/install/docker-compose



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
### HPA
```
kubectl apply -f immich-hpa-server.yaml
```
### Gateway route
(this assumes gateway is up and has the https route)

```
kubectl apply -f immich-httproute.yaml
```

## Migration / Import from immich-go.exe
https://github.com/simulot/immich-go/blob/main/docs/examples.md#server-migration

```
### Migration 

```
immich-go upload from-immich `
  --from-server=https//photos.3756home.org `
  --from-api-key=old-api-key `
  --server=http://pics.3756home.org `
  --api-key=new-api-key `
  --concurrent-tasks=1
```