# Datadog integration

## 1/5/25 - Using Datadog Operator
- Make datadog namespace
```
kubectl create ns datadog
```
- Goto Datadog integration page https://us5.datadoghq.com/account/settings/agent/latest?platform=kubernetes
- Pick API Key, have secret line created
- Paste text to command line, **Adjust to have namespace set to datadog**
```
helm repo add datadog https://helm.datadoghq.com
helm install datadog-operator datadog/datadog-operator -n datadog
kubectl create secret generic datadog-secret --from-literal api-key=<apikeyhere> -n datadog
```
3. Use datadog-operator.yaml file
```
kubectl apply -f datadog-operator.yaml -n datadog
```

