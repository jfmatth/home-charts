# Setting up Minecraft on my Talos Cluster

https://github.com/itzg/minecraft-server-charts


## Talos configs

### Setup in Traefik in Talos
Need to enable the experimental channel in Traefik, which should be done when installing Traefik helm chart
https://doc.traefik.io/traefik/reference/routing-configuration/kubernetes/gateway-api/#tcp

### Patch controlplanes to allow nodeport ranges for Minecraft
https://oneuptime.com/blog/post/2026-03-03-configure-nodeport-range-in-talos-linux/view

from talos folder and for each controlplane node
```
talosctl -n <CONTROLPLANE_IP> patch machineconfig --patch @talos-noderange-patch.yaml
```

## ITZG Charts for Minecraft
DAMM, this guy makes everything!
```
helm repo add itzg https://itzg.github.io/minecraft-server-charts/
kubectl apply -f minecraft-namespace.yaml
```

## mc-router
```
helm install mc-router itzg/mc-router -f mcrouter-values.yaml
```

## Minecraft server #1
```
helm install minecraft `
  --set minecraftServer.eula=true `
  -f minecraft-values.yaml `
  itzg/minecraft
```













## POC in Minikube
```
minikube start
```

### Helm chart from ITZG
https://github.com/itzg/minecraft-server-charts/tree/master

```
kubectl create namespace minecraft
kubectl config set-context minecraft --namespace=minecraft --user=minikube --cluster=minikube
kubectl config use-context minecraft
```

```
helm repo add itzg https://itzg.github.io/minecraft-server-charts/
```

```
helm install minecraft `
  --set minecraftServer.eula=true `
  -f minecraft-values.yaml `
  itzg/minecraft
```