# Building Talos-k8s (v1.84)

Our Cluster will have an API endpoint that is virtual, 192.168.100.130:6443, that is via the network changes below.  All nodes are DHCP which makes this easy.

The tough part was finding the ISO and target image for qemu guest agent features.

Basic cluster build
- Build ControlPlane on proxmox
- Build workers on bare-metal (lenovo)
- Apply-Config
- Bootstrap first Kubernetes node

## Download the ISO with QEMU agent support (for proxmox)
https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.8.4/nocloud-amd64.iso

## Build 5 VM's on Proxmox
3 x Control Plane  (2x2x32gb on Proxmox)  
- Enable QEMU Guest
- Set disk to write-back
- Attach ISO ```talos-qemu-nocloud64.iso``` to VM's

2 x Worker Nodes   (Physical Lenovo M910Q 4x32x256gb NVME)
- NVME01 disk


## Generate controlplane.yaml and worker.yaml files with patches
https://www.talos.dev/v1.8/talos-guides/install/virtualized-platforms/proxmox/#qemu-guest-agent-support

All controlplane nodes are on Proxmox and need QEMU support

Got this line from here https://factory.talos.dev/?arch=amd64&cmdline-set=true&extensions=-&extensions=siderolabs%2Fqemu-guest-agent&platform=nocloud&target=cloud&version=1.8.4

```
talosctl gen config talos-k8s https://192.168.100.130:6443 \
    --install-image factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.4 \
    --config-patch-control-plane @cp-1-patch.yaml \
    --config-patch-worker @nd-1-patch.yaml \
    --force
```

## Add first node with it's DHCP address
DHCP address may change after inital apply, check Proxmox
```
talosctl apply-config --insecure --nodes DHCP_ADDRESS_HERE --file controlplane.yaml
```

## Bootstrap Kubernetes
** Note ** - DHCP addresses change at home each reset of VM
```
talosctl --talosconfig=./talosconfig -n DHCP_ADDRESS_HERE -e DHCP_ADDRESS_HERE bootstrap
```

## Add more control planes, they bootstrap automagically
```
talosctl apply-config --insecure --nodes DHCP_ADDRESS_HERE --file controlplane.yaml
```

## Add worker nodes, create worker-o.yaml from patching, they bootstrap automagically
```
talosctl apply-config --insecure --nodes DHCP_ADDRESS_HERE --file worker.yaml
```

## SAVE YOUR talosconfig file
```
cp talosconfig ~/.talos/config
```

# Ingress
https://kubernetes.github.io/ingress-nginx/deploy/baremetal/

https://metallb.io/installation/#installation-by-manifest


## Namespace + MetalLB + IPPool + NGINX + IngressClass  
```
kubectl apply -f metallb-namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
kubectl apply -f metallb-ippool.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0-beta.0/deploy/static/provider/cloud/deploy.yaml
kubectl apply -f IngressClass.yaml
```
