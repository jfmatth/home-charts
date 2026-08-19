# Talos under Hyper-V lab

**might need to run this from a VM on the LabSwitch** just to be safe

## Requirements
- LabSwitch from this guide
- DC01 with
    - DHCP (assumes 100-200 range, 200+ is static)
    - NAT'ing traffic to Internet
    - DNS

## Talos Control Plane
- VM 2x2
- LabSwitch network
- ISO for Talos

```
boot-cp.ps1 <ip>
```

## Cilium
- Generate the .yaml files
- Add to ``cp-patch.yaml`` as ``InlineManifests:``  
(see https://docs.siderolabs.com/kubernetes-guides/advanced-guides/inlinemanifests)

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
