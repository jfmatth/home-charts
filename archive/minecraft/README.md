# Minecraft server for home

Uses https://github.com/itzg/minecraft-server-charts/tree/master/charts/minecraft

## installation

```
kubectl create namespace minecraft
helm repo add itzg https://itzg.github.io/minecraft-server-charts/
helm install minecraft itzg/minecraft -n minecraft -f values.yaml
```

## values.yaml
Main changes to yaml
- Turn on LoadBalancer
- Memory request at 1M
- CPU request to 1 CPU
- Persistence turned on 

