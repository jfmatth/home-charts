# Monitoring for the home k3s stack


using https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack


```
helm install prometheus -n monitoring prometheus-community/kube-prometheus-stack -f home-values.yaml
```

