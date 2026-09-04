# Talos under Hyper-V lab **WIP**


## Requirements
- LabSwitch from this guide
- DNS / DHCP Server on Labswitch (See DNSMASQ folder above)

## VM's

### Control Plane
- VM 2x2
- LabSwitch network
- ISO for Talos
- Settings
    - Set Boot order to Disk->ISO
    - Remove Secure Boot
    - Set CPU to 2

### Worker(s)
- VM 1x2+
- LabSwitch network
- ISO for Talos
- Settings
    - Set Boot order to Disk->ISO
    - Remove Secure Boot
    - Set CPU to 2


## Install Control Plane

```
.\build-cp.ps1 [IP of Control Plane]
```
- Debug requires Enter on various Steps

After healthcheck passes, two pods will not start, core-dns due to no network yet.

### Cilium 
- Install Cilium via HELM (see Talos folder)


```
kubectl apply -f cilium-ippool.yaml
```

## Install Workers
```
talosctl apply-config --insecure --node [IP of Worker] --file .\cluster-configs\worker.yaml
```

## Design of folders and scripts
Learned a lot about Powershell, how bad it is really, but none-the-less it's what is used since I'm a Windows guy :)

- control-plane-patches - these are added as individual --patch-control-plane during ``talosctl gen config`` section, so they must not overlap

## Traefik (from Talos docs - https://docs.siderolabs.com/kubernetes-guides/advanced-guides/deploy-traefik#deploy-traefik-as-a-gateway-api)
```
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm upgrade --install traefik traefik/traefik `
  -n traefik --create-namespace `
  -f traefik-basic.yaml
```

## Cilium
https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium#machine-configuration-prerequisites


- Generate the .yaml files
- Add to ``cp-patch.yaml`` as ``InlineManifests:``  
(see https://docs.siderolabs.com/kubernetes-guides/advanced-guides/inlinemanifests)

Versions Tested:
- 1.18.0
- 1.18.13
- 1.19.7 - with KubeProxy
- 1.20.1

### Generate inline manifests **with Kube-proxy**  
```
helm template `
    cilium `
    cilium/cilium `
    --version 1.18.0 `
    --namespace kube-system `
    --set ipam.mode=kubernetes `
    --set kubeProxyReplacement=false `
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" `
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" `
    --set cgroup.autoMount.enabled=false `
    --set cgroup.hostRoot=/sys/fs/cgroup > hold\cilium-kubeproxy.yaml
```

### Generate inline manifests **without Kube-proxy**  
```
helm template `
    cilium `
    cilium/cilium `
    --namespace kube-system `
    --set ipam.mode=kubernetes `
    --set kubeProxyReplacement=true `
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" `
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" `
    --set cgroup.autoMount.enabled=false `
    --set cgroup.hostRoot=/sys/fs/cgroup `
    --set k8sServiceHost=localhost `
    --set k8sServicePort=7445 > hold\cilium-nokubeproxy.yaml
```

### Generate inline manifests **without Kube-proxy and with GatewayAPI**  
https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/#cilium-gateway-api-support

```
helm template `
    cilium `
    cilium/cilium `
    --namespace kube-system `
    --set ipam.mode=kubernetes `
    --set kubeProxyReplacement=true `
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" `
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" `
    --set cgroup.autoMount.enabled=false `
    --set cgroup.hostRoot=/sys/fs/cgroup `
    --set k8sServiceHost=localhost `
    --set gatewayAPI.enabled=true `
    --set k8sServicePort=7445 > hold\cilium-nokubeproxy-gateway.yaml
```
