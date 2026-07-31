# Talos Testing in PowerShell

Use Hyper-V to test various new builds or Cilium upgrades

## Build Single VM on Hyper-V
- Default Switch
- 2x4, no dynamic memory
- Turn off TSM
- Boot and record IP
```
$env:CPIP="IP GOES HERE"
$env:NAME="TalosTesting"
```

### Testing Cilium versions
https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium#method-2-helm

**without kube-proxy**

