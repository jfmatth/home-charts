# Monitoring for the home k3s stack


using https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack


```
helm install prometheus --create-namespace -n monitoring prometheus-community/kube-prometheus-stack -f home-values.yaml
```

## Install Loki too
```
helm install loki-stack grafana/loki-stack -n monitoring --set promtail.enabled=true,loki.persistence.enabled=true,loki.persistence.size=10Gi
```