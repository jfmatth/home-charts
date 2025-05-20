# Monitoring for the home k3s stack

Assuming you have helm installed and working :O

using https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus --create-namespace -n monitoring prometheus-community/kube-prometheus-stack -f home-values.yaml
```

## Install Loki
<!-- ```
helm install loki-stack grafana/loki-stack -n monitoring --set promtail.enabled=true,loki.persistence.enabled=true,loki.persistence.size=2Gi
``` -->

```
helm install loki-stack grafana/loki-stack -n monitoring -f loki-values.yaml
```