# Minikube install to play around with K8s on laptops

## Install
https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe+download  

```
winget install kubernetes.minikube
```
### Hyper-V and ContainerD
```
minikube config set vm-driver hyperv
minikube config set container-runtime containerd
```

### Start
```
minikube start
```

It should update your kubectl config to add a new context  

## CloudNativePG - CNCF Postgres operator
https://cloudnative-pg.io/docs/1.29/quickstart  

### Install
```
kubectl apply --server-side -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.29/releases/cnpg-1.29.1.yaml
```

