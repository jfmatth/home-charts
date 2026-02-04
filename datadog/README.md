# Talos Datadog integration

## Home installation
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
kubectl create secret generic datadog-secret --from-literal api-key=  --namespace=datadog
```

Install the helm chart for Talos, not the operator
```
helm install datadog datadog/datadog -f datadog-values.yaml -n datadog
```
<!-- ```
 --namespace datadog `
 --set
 --set datadog.kubelet.tlsVerify=false `
 --set providers.talos.enabled=true `
 --set datadog.clusterName=talos-k8s `
 --set agents.image.tag=7.67.0-rc.2
```

# Commands to install Datadog Agent in a GKE Autopilot Cluster

## Create a secret in the namespace admin-datadog
> kubectl create secret generic datadog-secret --from-literal api-key=pasteyourkeyhere --namespace=admin-datadog

## Add Datadog Helm Repo
> helm repo add datadog https://helm.datadoghq.com

> helm repo update

## Deploy Agent with the datadog-values.yaml configuration file
> helm install datadog-agent -f ps-gcp-gke-autopilot/sandbox/manifests/admin-datadog/datadog-values.yaml datadog/datadog --namespace=admin-datadog --version 3.118.0  -->


### Refrence
https://us5.datadoghq.com/account/settings/agent/latest?platform=kubernetes  
https://docs.datadoghq.com/containers/kubernetes/distributions/?tab=helm#autopilot  
https://github.com/DataDog/helm-charts/tree/main/charts/datadog#all-configuration-options  
https://www.datadoghq.com/blog/gke-autopilot-monitoring/  


## Notes from datadog training
Autodiscovery is a Datadog feature that identifies automatically the workloads running in a container and enables its corresponding integrations to gather relevant metrics for those services.  

The Node Agent running on the control plane Node discovers the Kubernetes components running on it and enables those integrations. You can check what integrations are discovered by running the following command:
```bash
copy
run
kubectl exec -ti $(kubectl get pods -l agent.datadoghq.com/component=agent --field-selector spec.nodeName=kubernetes -o name) -- agent configcheck
```
On that output you will see integrations like kubelet, kube_scheduler, kube_controller_manager, kube_apiserver_metrics, etcd and others related to system metrics.


Now run the agent status command to check the status of those integrations:
```kubectl exec -ti $(kubectl get pods -l agent.datadoghq.com/component=agent --field-selector spec.nodeName=kubernetes -o name) -- agent status collector
As you browse the output of that command, you will see that the etcd integration (or check) is failing:
  Check Initialization Errors
  ===========================
      etcd (8.1.0)
      ------------
      instance 0:
        could not invoke 'etcd' python check constructor. New constructor API returned:
Traceback (most recent call last):
  File "/opt/datadog-agent/embedded/lib/python3.11/site-packages/datadog_checks/etcd/etcd.py", line 74, in __init__
    super(Etcd, self).__init__(
  File "/opt/datadog-agent/embedded/lib/python3.11/site-packages/datadog_checks/base/checks/openmetrics/base_check.py", line 126, in __init__
    raise CheckException(
datadog_checks.base.errors.CheckException: The agent could not connect to any of the following URLs: ['https://10.5.0.155:2379/metrics', 'http://10.5.0.155:2379/metrics'].
Deprecated constructor API returned:
Etcd.__init__() got an unexpected keyword argument 'agentConfig'
```

The reason the Datadog Agent cannot communicate with the etcd Pod is that it doesn't have access to the needed certificates. You will be following the official documentation where it is recommended mounting the host path where the etcd certificates are located, and modify the check configuration through a ConfigMap.
Open the Editor tab, select the datadog-etcd.yaml file, and explore the contents. Check the differences between this file and the previous one.
You can also check the differences between these two files by executing the following command:
bash
copy
run
diff -U1 --color /root/lab/manifest-files/datadog/datadog-tolerations.yaml /root/lab/manifest-files/datadog/datadog-etcd.yaml
Break down what this new configuration is trying to achieve.
By adding the extraConfd key to the DatadogAgent definition you are telling the Agent where to look for additional checks configuration (in this case, in a ConfigMap).
yaml
  extraConfd:
    configMap:
      name: datadog-checks
By adding the following volume and volume mounts you are disabling the default etcd configuration:
yaml
volumes:
- hostPath:
- name: disable-etcd-autoconf
  emptyDir: {}
volumeMounts:
- name: disable-etcd-autoconf
  mountPath: /etc/datadog-agent/conf.d/etcd.d
By adding the following volume and volume mounts you are mounting the etcd certificates folder into the Datadog Agent Pods:
yaml
volumes:
- hostPath:
    path: /etc/kubernetes/pki/etcd
  name: etcd-certs
volumeMounts:
- name: etcd-certs
  mountPath: /host/etc/kubernetes/pki/etcd
  readOnly: true
Finally, the ConfigMap with the new configuration for the etcd check is created, passing the certificates and keys path from the Agent volume mounts:
yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: datadog-checks
data:
  etcd.yaml: |-
    ad_identifiers:
      - etcd
    init_config:
    instances:
      - prometheus_url: https://%%host%%:2379/metrics
        tls_ca_cert: /host/etc/kubernetes/pki/etcd/ca.crt
        tls_cert: /host/etc/kubernetes/pki/etcd/server.crt
        tls_private_key: /host/etc/kubernetes/pki/etcd/server.key
Apply this new configuration:
bash
copy
run
kubectl apply -f /root/lab/manifest-files/datadog/datadog-etcd.yaml
Wait until the Node Agent Pod deployed on the kubernetes Node is running again:
bash
copy
run
kubectl get pods -l agent.datadoghq.com/component=agent -o wide
NAME                  READY   STATUS    RESTARTS   AGE   IP               NODE         NOMINATED NODE   READINESS GATES
datadog-agent-cxtwq   2/2     Running   0          12m   192.168.171.69   worker       <none>           <none>
datadog-agent-g8xxp   2/2     Running   0          12m   192.168.192.73   kubernetes   <none>           <none>
After the Pod is running again, rerun the status command:
bash
copy
run
kubectl exec -ti $(kubectl get pods -l agent.datadoghq.com/component=agent --field-selector spec.nodeName=kubernetes -o name) -- agent status collector
You can see that now the etcd check is running correctly:
etcd (8.1.0)
------------
Instance ID: etcd:7626e3d63d7d227a [OK]
Configuration Source: file:/etc/datadog-agent/conf.d/etcd.yaml
Total Runs: 2
Metric Samples: Last Run: 1,123, Total: 2,246
Events: Last Run: 0, Total: 0
Service Checks: Last Run: 1, Total: 2
Average Execution Time : 93ms
Last Execution Date : 2025-03-26 09:59:05 UTC (1742983145000)
Last Successful Execution Date : 2025-03-26 09:59:05 UTC (1742983145000)
metadata:
  version.major: 3
  version.minor: 5
  version.patch: 7
  version.raw: 3.5.7
  version.scheme: semver

From <https://play.instruqt.com/embed/datadog/tracks/monitoring-kubernetes/challenges/set-up-your-datadog-account/assignment#tab-0> 


```
datadog:
  ignoreAutoConfig:
    - redisdb
    - istio
    - cilium
  site: "us5.datadoghq.com"
  clusterName: "sndbx-autopilot-private-cluster"
  apiKeyExistingSecret: "datadog-secret"
  kubelet:
    useApiServer: true
  tags:
    - "env:staging"
  apm:
    instrumentation:
      enabled: true
      targets:
        - name: "default-target"
          ddTraceVersions:
            java: "1"
            python: "3"
            js: "5"
            php: "1"
            dotnet: "3"
  logs:
    enabled: true
    containerCollectAll: true
  # networkMonitoring:
  #   enabled: true
  processAgent:
    processCollection: true
agents:
  containers:
    agent:
      resources:
        requests:
          cpu: "200m"
          memory: "256Mi"
    traceAgent:
      resources:
        requests:
          cpu: "100m"
          memory: "200Mi"
    processAgent:
      resources:
        requests:
          cpu: "100m"
          memory: "200Mi"
    systemProbe:
      resources:
        requests:
          cpu: "100m"
          memory: "400Mi"
  priorityClassCreate: true
providers:
  gke:
    autopilot: true

  #List of integration(s) to ignore auto_conf.yaml.
```