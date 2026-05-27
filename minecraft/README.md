# Setting up Minecraft on my Talos Cluster

https://github.com/itzg/minecraft-server-charts



## Experimenting in Minikube

```
minikube start
```

### Helm chart from ITGZ
https://github.com/gilesknap/k3s-minecraft

```
kubectl create namespace minecraft
kubectl config set-context minecraft --namespace=minecraft --user=minikube --cluster=minikube
kubectl config use-context minecraft
```
