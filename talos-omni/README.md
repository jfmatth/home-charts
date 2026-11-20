# Talos Omni build (at home)

## Requirements
- Omnictl
- Logged into Omni account
- Helm


## Build the cluster?

### Cilium setup
https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium#method-1-omni-manifest-sync

```
helm repo add cilium https://helm.cilium.io/
helm repo update
helm template `
    cilium `
    cilium/cilium `
    --version 1.20.5 `
    --namespace kube-system `
    --values cilium-values.yaml > cilium.yaml
```

### Boot VM's for CP / WO

- Boot VM's on Proxmox for CP and WO nodes
- 1xCP, 3xWO
- Label them in UI for various roles (role:controlplane or role:worker)
```
omnictl apply -f machine-class.yaml
```

### Create cluster
```
omnictl cluster template sync --file omni-cluster.yaml
```
Cluster takes ~5m to fully boot

### Download config for Kubectl

### Cilium L2 / Pool
```
kubectl apply -f cilium-announce.yaml
kubectl apply -f cilium-ippool.yaml
```

### Traefik
https://github.com/traefik/traefik-helm-chart/tree/master

### Gateway CRD's
As of Traefik, gateway CRD's need to be installed

Standard
```
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml
```
Experimental (needed for Minecraft TCPRoute)  
```
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/experimental-install.yaml
```


**This will throw warnings, don't be alarmed**
### Traefik install
```
kubectl apply -f traefik-namespace.yaml
helm install traefik traefik/traefik -f .\traefik.yaml -n traefik
kubectl apply -f traefik-gateway.yaml
```
This will create a Traefik load balancer service which is where the gateway will connect
#### References
https://github.com/traefik/traefik-helm-chart/blob/master/traefik/VALUES.md
https://doc.traefik.io/traefik/setup/kubernetes/#prepare-helm-chart-configuration-values  
https://doc.traefik.io/traefik/routing/providers/kubernetes-gateway/#traefik-kubernetes-with-gateway-api  

