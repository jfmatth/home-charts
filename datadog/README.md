# Datadog integration

## Talos - Home installation
- Make datadog namespace
```
kubectl apply -f datadog-namespace.yaml
```
- Goto Datadog integration page https://us5.datadoghq.com/account/settings/agent/latest?platform=kubernetes
- Helm Chart not Operator
- Pick API Key, copy it to clipboard

- Modify the default text below with the API key
```
helm repo add datadog https://helm.datadoghq.com
helm repo update
kubectl create secret generic datadog-secret --namespace=datadog --from-literal api-key=
```

Install the helm chart
```
helm install datadog datadog/datadog -f datadog-values.yaml -n datadog
```

## K3s - Internet installation
- Make namespace
```
kubectl create ns datadog
```
- Goto Datadog integration page https://us5.datadoghq.com/account/settings/agent/latest?platform=kubernetes
- Helm Chart not Operator
- Pick API Key, copy it to clipboard
- Modify the default text below with the API key
```
helm repo add datadog https://helm.datadoghq.com
helm repo update
kubectl create secret generic datadog-secret --namespace=datadog --from-literal api-key=
```

Install the helm chart
```
helm install datadog datadog/datadog -f datadog-values.yaml -n datadog --set providers.talos.enabled=false
```
