# Setting up Minecraft on my Talos Cluster

https://github.com/itzg/minecraft-server-charts



## Experimenting in Minikube

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
cd minecraft-server-charts\charts\minecraft
helm install minecraft `
  --set minecraftServer.eula=true `
  itzg/minecraft
```