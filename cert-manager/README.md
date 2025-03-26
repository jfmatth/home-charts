https://cert-manager.io/docs/installation/helm/#installing-cert-manager

We will just modify the "gateway.yaml" file for new http / https endpoints (i.e. example.home3756.org, test.home...)


## Certmanager for Gateway API

```
 helm repo add jetstack https://charts.jetstack.io --force-update
 helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.0  \
  --set crds.enabled=true \
  --set "extraArgs={--enable-gateway-api}"
```

## Let's Encrypt ClusterIssuer

```
kubectl apply -f talos-clusterissuer.yaml -n cert-manager
```