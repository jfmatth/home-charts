# Datadog integration

https://us5.datadoghq.com/account/settings/agent/latest?platform=kubernetes

## create namespace
```
kubectl create ns datadog
```

## Create API Key
```
kubectl create secret generic datadog-secret --from-literal api-key=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

## Deploy
```
helm install datadog-agent -f datadog-values.yaml datadog/datadog -n datadog
```