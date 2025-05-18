https://cert-manager.io/docs/installation/helm/#installing-cert-manager

# Certmanager in Talos install

- We already have the gateway CRDs installed
- Need to tell certmanager this is for Gateway API

```
helm install `
  cert-manager jetstack/cert-manager `
  --namespace cert-manager `
  --create-namespace `
  --version v1.17.2 `
  --set config.enableGatewayAPI=true `
  --set crds.enabled=true

```

## Add cert-manager-gateway for issuer
```
kubectl apply -f gateway-certmanager.yaml
```

## Add Issuer
```
kubectl apply -f clusterissuer.yaml
```


## References

https://cert-manager.io/docs/configuration/acme/http01/#configuring-the-http-01-gateway-api-solver

