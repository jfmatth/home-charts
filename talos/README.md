# Building Talos-k8s

Patch files
- cp-1-patch.yaml
    - Virtual L2 Talos API endpoint (192.168.100.130)
    - Certificate rotation for metrics-server
    - Metrics server
    - Cilium
- nd-1-patch.yaml
    - If running on Lenovo bare metal, this commented patch allows it to load onto NVME instead of SSD
    - Cilium 

## Preparation
- Version 1.10.1 Proxmox QEMU

https://factory.talos.dev/?arch=amd64&cmdline-set=true&extensions=-&extensions=siderolabs%2Fqemu-guest-agent&platform=nocloud&target=cloud&version=1.10.1

For images and upgrades
factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.10.1


## Build VM's
- ControlPlane - 2x2 with guest agent
- Worker node - 4x16 with guest agent

## Build files

### Cilium Yaml (if a new version is out, current is 1.17.3)


## Control Plane 
```
bootcp.bat <IP>
```

## additional nodes
```
addrole.bat <ip> <controlplane.yaml | worker.yaml>
```














## Generate controlplane.yaml and worker.yaml files with patches

Linux
```
talosctl gen config talos-k8s https://192.168.100.130:6443 \
    --install-image factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.9.4 \
    --config-patch-control-plane @cp-1-patch.yaml \
    --config-patch-worker @nd-1-patch.yaml \
    --force
```
Powershell
```
talosctl gen config talos-k8s https://192.168.100.130:6443 `
    --install-image factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.9.4 `
    --config-patch-control-plane @cp-1-patch.yaml `
    --config-patch-worker @nd-1-patch.yaml `
    --force
```

## Build control plane

### Set IP of first node, check Proxmox

Linux
```
export IP=IPofVM
```
Powershell
```
$IP="192.168.100."
```
### Build first control plane node
```
talosctl apply-config --insecure --nodes $IP --file controlplane.yaml
```

### Bootstrap Kubernetes (Check IP, it may have changed)
```
talosctl --talosconfig=./talosconfig -n $IP -e $IP bootstrap
```

### Add Cilium here
https://www.talos.dev/v1.9/kubernetes-guides/network/deploying-cilium/#method-4-helm-manifests-inline-install

WORKS!


## Add more control planes, they bootstrap automagically
```
talosctl apply-config --insecure --nodes DHCP_ADDRESS_HERE --file controlplane.yaml
```

## Build worker nodes

Run below on as many worker nodes as you have

### Add worker nodes, create worker-o.yaml from patching, they bootstrap automagically
```
talosctl apply-config --insecure --nodes DHCP_ADDRESS_HERE --file worker.yaml
```

## SAVE YOUR talosconfig file and set endpoints
```
cp talosconfig ~/.talos/config
talosctl config endpoint 192.168.100.130
talosctl config node 192.168.100.130
talosctl kubeconfig -f
```

## [Upgrades](https://www.talos.dev/v1.10/talos-guides/upgrading-talos/)
1.94 -> 1.10.0  
**make sure to get the right image for QEMU**
```
talosctl upgrade --nodes 192.168.100.130 --image ghcr.io/siderolabs/installer:v1.10.0
```

# Load Balancer / Gateway API setup
Instead of an ingress controller, we are using the new Gateway API in Kubernetes 1.2+

## MetalLB Load Balancer  

```
kubectl apply -f metallb-namespace.yaml
```

Helm install
```
helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb -n metallb-system -f metallb-values.yaml
```

```
kubectl apply -f metallb-ippool.yaml
```

<!-- 
```
kubectl apply -f ns-network.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
kubectl apply -f metallb-ippool.yaml
``` -->

## Traefik Gateway API

**The helm chart from Traefik handles all necessary CRD's and RBAC**
```
kubectl create ns traefik
helm install traefik oci://ghcr.io/traefik/helm/traefik -f traefik-values.yaml -n traefik
```


## Cert-manager

```
 helm repo add jetstack https://charts.jetstack.io --force-update
 helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.0  \
  --set crds.enabled=true \
  --set "extraArgs={--enable-gateway-api}"
```