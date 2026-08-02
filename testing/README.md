# Talos Testing in PowerShell

Use Hyper-V to test various new builds or Cilium upgrades

## Build Single VM on Hyper-V
- Default Switch
- 2x4, no dynamic memory
- Turn off TSM
- Boot and record IP
- Set the following variables

```
CPIP="IP GOES HERE"
```

### Testing Cilium versions
https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium#method-2-helm


```
$helmOutput = $(`
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
    --set cgroup.hostRoot=/sys/fs/cgroup
)

(Get-Content cilium-header.yaml), $helmOutput | Set-Content cilium-patch.yaml

talosctl gen config talostesting https://$env:CPIP:6443 `
    --config-patch-control-plane @cilium-patch.yaml `
    --force
```