# Hosting changedetection.io on K8s

Using ```https://github.com/chris2k20/helm-charts/tree/main/charts/changedetectionio```

## Install
```
kubectl create ns changedetector
helm repo add chris2k20 https://chris2k20.github.io/helm-charts/
helm install changedetectionio chris2k20/changedetectionio \
  -n changedetector \
  -f values.yaml
