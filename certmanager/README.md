# Certmanager installation 


Taken from Talos Readme.md

https://cert-manager.io/docs/installation/helm/


## Helm install for Certmanager

```
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl apply -f cert-manager-namespace.yaml
helm install cert-manager jetstack/cert-manager --namespace cert-manager -f cert-manager-standard.yaml
```

## ClusterIssuer
```
kubectl apply -f cert-manager-clusterissuer.yaml
```