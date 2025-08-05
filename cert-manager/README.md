https://cert-manager.io/docs/installation/helm/#installing-cert-manager

# Certmanager in Talos install

- We already have the Kubernetes gateway api CRDs installed from Cilium

```
helm install cert-manager jetstack/cert-manager --namespace cert-manager  --create-namespace -f cert-manager.yaml
```

ORIG
```
helm install `
  cert-manager jetstack/cert-manager `
  --namespace cert-manager `
  --create-namespace `
  --set config.enableGatewayAPI=true `
  --set crds.enabled=true `
  --set "extraArgs={--feature-gates=ExperimentalGatewayAPISupport=true}"
```

<!-- ## Add the resolver gateway first
This gateway only routes HTTP port 80 traffic, no listeners defined.  It allows the clusterissuer to setup HTTPRoutes to it's solver.  This will reside in the cert-manager namespace.

```
kubectl apply -f gateway-certmanager.yaml
``` -->

## Add Issuer
```
kubectl apply -f clusterissuer.yaml
```

<!-- ## Add cert-manager-gateway for issuer
This is the annotated gateway that certmanager will pickup on and create HTTPRoutes for.

For whatever reason I was unable to combine the two into one file, oh well.
```
kubectl apply -f gateway-certmanager.yaml
``` -->


## References

https://cert-manager.io/docs/configuration/acme/http01/#configuring-the-http-01-gateway-api-solver

