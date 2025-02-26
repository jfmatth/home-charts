# Building Talos-k8s (v1.84)


Patch files
- cp-1-patch.yaml
    - Virtual L2 Talos API endpoint (192.168.100.130)
    - Certificate rotation for metrics-server
    - Metrics server
- nd-1-patch.yaml
    - If running on Lenovo bare metal, this commented patch allows it to load onto NVME instead of SSD

## Preparation
- Download the ISO with QEMU agent support (for proxmox) from https://factory.talos.dev/
    - 1.9.4 page 
        - https://factory.talos.dev/?arch=amd64&cmdline-set=true&extensions=-&extensions=siderolabs%2Fqemu-guest-agent&platform=metal&target=metal&version=1.9.4
- Build Control Plane VM's (2x2x32gb on Proxmox, **Enabled QEMU Guest**)
- Enable QEMU Guest

## Generate controlplane.yaml and worker.yaml files with patches
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
export IP=IPofVM
talosctl apply-config --insecure --nodes $IP --file controlplane.yaml
```

## Bootstrap Kubernetes
** Note ** - DHCP addresses change at home each reset of VM
```
talosctl --talosconfig=./talosconfig -n $IP -e $IP bootstrap
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

# Gateway API setup
Instead of an ingress controller, we are using the new Gateway API in Kubernetes 1.2+

## MetalLB Load Balancer  
```metallb-ippool.yaml``` contains the IP addresses that will answer the external gateway 'call', this should be where the outside router points to (eventually)

```
kubectl apply -f metallb-namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
kubectl apply -f metallb-ippool.yaml
```
## Kubernetes gateway API 1.2
https://gateway-api.sigs.k8s.io/guides/#installing-gateway-api

```
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml
```

## NGINX Gateway Fabric
https://docs.nginx.com/nginx-gateway-fabric/installation/installing-ngf/manifests/

Due to Talos' security restrictions, the namespace yaml needs to specify relaxed security.

Namespace + CRD + Fabric
```
kubectl apply -f nginx-namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v1.6.1/deploy/crds.yaml
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