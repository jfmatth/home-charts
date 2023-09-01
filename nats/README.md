# Nats.io https://artifacthub.io/packages/helm/nats/nats

```
kubectl create ns nats
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm upgrade --install nats nats/nats -f values.yaml -n nats
```
