# Building Talos-k8s (v1.12.2)

Patch files
- cp-1-patch.yaml
    - Virtual L2 Talos API endpoint (192.168.100.140)
    - Certificate rotation for metrics-server
    - Metrics server
    - Gateway API manifests
    - Cilium preparation (kube-proxy off, no CNI)
- nd-1-patch.yaml
    - If running on Lenovo bare metal, this commented patch allows it to load onto NVME instead of SSD

## Preparation
- Version 1.12.2 Proxmox QEMU  
    https://factory.talos.dev/?arch=amd64&bootloader=auto&cmdline-set=true&extensions=-&extensions=siderolabs%2Fqemu-guest-agent&platform=nocloud&target=cloud&version=1.12.2

For images and upgrades
    ```factory.talos.dev/nocloud-installer/17bd088c71807ae797c16e85efb133b27814f1a333312bf597c3d4bc6f7c13d7:v1.12.2```

## Build VM's
- ControlPlane - 2x2 with guest agent (x3)
- Worker node - 4x16 with guest agent (x2)

## Install Control Plane
You need to build the control plane nodes, then add Cilium since we've turned off kube-proxy from Talos

### First Controlplane node
```
bootcp.bat <IP>
```

***Wait for a few pods to spin up***

### Install Cilium 

(as of 2/3/26, v1.19.x didn't work, Talos docs use 1.18.x)

```
helm install cilium cilium/cilium --namespace kube-system -f cilium.yaml --version 1.18.6
```

**Notes**
- Watch for pods to spin up.  Since only one CP is alive, the other Cillium-operator won't start, that's OK.
- Metrics server won't start either since we don't have any worker nodes
- The CoreDNS pods have to start so we can resolve host name

```
kubectl apply -f cilium-announce.yaml
kubectl apply -f cilium-ippool.yaml
```

### Additional ControlPlane nodes
```
addrole.bat <ip> controlplane.yaml 
```
After all ControlPlane nodes are up, there should be no pods that aren't running N/N.

### Restart Cilium
```
kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart ds/cilium
```
**Wait until all Cilium pods have restarted**

## Worker nodes
```
addrole.bat <ip> worker.yaml
```
 
## Metrics Server
Moved metrics server install to helm chart due to TLS issues and the way our cluster is setup
```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system -f .\metrics-server.yaml
```

### Datadog
See Datadog folder and follow ```README.md```

## Traefik Gateway API

### Namespace + Traefik + Gateway 
```
kubectl apply -f traefik-namespace.yaml
helm install traefik traefik/traefik -f .\traefik.yaml -n traefik
kubectl apply -f traefik-gateway.yaml
```
This will create a Traefik load balancer service which is where the gateway will connect

### References
https://github.com/traefik/traefik-helm-chart/blob/master/traefik/VALUES.md  
https://doc.traefik.io/traefik/setup/kubernetes/#prepare-helm-chart-configuration-values  
https://doc.traefik.io/traefik/routing/providers/kubernetes-gateway/#traefik-kubernetes-with-gateway-api  


## NFS Storage
```
helm install nfs-storage nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --namespace kube-system -f nfs.yaml
```

## Cert-manager
See Cert-Manager folder for instructions

## Postgres Operator
See postgres-zalando folder
