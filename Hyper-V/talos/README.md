# Talos under Hyper-V lab

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

## Install Workers
```
talosctl apply-config --insecure [IP of Worker] --file .\cluster-configs\worker.yaml
```

## Cilium
- Generate the .yaml files
- Add to ``cp-patch.yaml`` as ``InlineManifests:``  
(see https://docs.siderolabs.com/kubernetes-guides/advanced-guides/inlinemanifests)

Versions Tested:
- 1.18.0
- 1.18.13
- 1.19.x - Fails to get cert :()

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
    --set cgroup.hostRoot=/sys/fs/cgroup > cilium-kubeproxy.yaml
```

### Generate inline manifests **without Kube-proxy**  

```
helm template `
    cilium `
    cilium/cilium `
    --version 1.18.0 `
    --namespace kube-system `
    --set ipam.mode=kubernetes `
    --set kubeProxyReplacement=true `
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" `
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" `
    --set cgroup.autoMount.enabled=false `
    --set cgroup.hostRoot=/sys/fs/cgroup `
    --set k8sServiceHost=localhost `
    --set k8sServicePort=7445 > cilium-nokubeproxy.yaml
```
