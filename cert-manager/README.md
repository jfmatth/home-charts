https://cert-manager.io/docs/installation/helm/#installing-cert-manager


# Talos


```
kubectl apply -f talos-clusterissuer.yaml -n cert-manager
```
## Annotated gateway example
https://cert-manager.io/docs/usage/gateway/

All requests are in Gateway with above
```
kubectl apply -f talos-gateway.yaml -n cert-manager
```


## Certificate method
https://cert-manager.io/docs/configuration/acme/http01/#configuring-the-http-01-gateway-api-solver

```
kubectl apply -f talos-gateway.yaml
kubectl apply -f talos-clusterissuer.yaml
```
