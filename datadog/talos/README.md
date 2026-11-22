# Talos Datadog integration

## Home installation
- Make datadog namespace
    ```
    kubectl apply -f datadog-namespace.yaml
    ```

- Setup Datadog Operator via agent page https://us5.datadoghq.com/account/settings/agent/latest?platform=kubernetes
- See specifics on Talos  
https://docs.datadoghq.com/containers/kubernetes/control_plane/?tab=datadogoperator#TalosLinux