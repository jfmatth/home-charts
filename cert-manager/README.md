https://cert-manager.io/docs/installation/helm/#installing-cert-manager

# Certmanager in Talos install

- We already have the Kubernetes gateway api CRDs installed from Cilium

```
kubectl apply -f cert-manager-namespace.yaml
helm install cert-manager jetstack/cert-manager --namespace cert-manager  --create-namespace -f cert-manager.yaml
```

## Add Issuer
```
kubectl apply -f clusterissuer.yaml
```

### References

https://cert-manager.io/docs/configuration/acme/http01/#configuring-the-http-01-gateway-api-solver

