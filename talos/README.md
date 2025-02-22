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

## Build Control Plane on Proxmox
3 x Control Plane  (2x2x32gb on Proxmox)  
- Enable QEMU Guest


## Generate controlplane.yaml and worker.yaml files with patches
Goto https://factory.talos.dev and generate the ISO / images for QEMU support

```
talosctl gen config talos-k8s https://192.168.100.130:6443 \
    --install-image factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.9.4 \
    --config-patch-control-plane @cp-1-patch.yaml \
    --config-patch-worker @nd-1-patch.yaml \
    --force
```

## Add first node with it's DHCP address
DHCP address may change after inital apply, check Proxmox
```
talosctl apply-config --insecure --nodes IP --file controlplane.yaml
```

## Bootstrap Kubernetes
** Note ** - DHCP addresses change at home each reset of VM
```
talosctl --talosconfig=./talosconfig -n IP -e IP bootstrap
```

## Add more control planes, they bootstrap automagically
```
talosctl apply-config --insecure --nodes DHCP_ADDRESS_HERE --file controlplane.yaml
```

## Add worker nodes, create worker-o.yaml from patching, they bootstrap automagically
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

## MetalLB Load Balancer  
```
kubectl apply -f metallb-namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
kubectl apply -f metallb-ippool.yaml
```
## Kubernetes gateway API
https://gateway-api.sigs.k8s.io/guides/#installing-gateway-api

```
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml
```

## NGINX Gateway Fabric
https://docs.nginx.com/nginx-gateway-fabric/installation/installing-ngf/manifests/

Namespace
```
kubectl apply -f nginx-namespace.yaml
```

CRD's
```
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v1.6.1/deploy/crds.yaml
```

Gateway Fabric
```
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v1.6.1/deploy/default/deploy.yaml
```

### Verify gateway is working
https://docs.nginx.com/nginx-gateway-fabric/get-started/#create-an-example-application

```
kubectl apply -f cafe.yaml
kubectl get pods
kubectl apply -f cafe-gateway.yaml
kubectl apply -f cafe-routes.yaml
kubectl get service -A
kubectl describe httproutes
kubectl describe gateway
```