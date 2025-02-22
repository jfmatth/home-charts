# Talos Datadog integration

- Make datadog namespace
```
kubectl apply -f datadog-namespace.yaml
```
- Goto Datadog integration page https://us5.datadoghq.com/account/settings/agent/latest?platform=kubernetes
- Use Helm Chart (not operator)
- Pick API Key, have secret line created

```
helm install datadog-agent -f datadog-values.yaml datadog/datadog -n datadog
```