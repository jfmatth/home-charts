# Talos Omni build (at home)

## Requirements
- Omnictl
- Logged into Omni account
- Helm


## Build the cluster?

### Cilium setup
https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium#method-1-omni-manifest-sync

```
helm repo add cilium https://helm.cilium.io/
helm repo update
helm template `
    cilium `
    cilium/cilium `
    --version 1.20.5 `
    --namespace kube-system `
    --values cilium-values.yaml > cilium.yaml
```

```
omnictl apply -f machine-class.yaml
```

```
omnictl cluster template sync --file omni-cluster.yaml
```

## Add machines as control-plane nodes via the UI
- Add role:controlplane as a label to move it to the control plane class



