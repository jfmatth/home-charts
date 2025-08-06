# Building Talos-k8s (v1.10.6)

Patch files
- cp-1-patch.yaml
    - Virtual L2 Talos API endpoint (192.168.100.140)
    - Certificate rotation for metrics-server
    - Metrics server
- nd-1-patch.yaml
    - If running on Lenovo bare metal, this commented patch allows it to load onto NVME instead of SSD

## Preparation
- Version 1.10.6 Proxmox QEMU  
    https://factory.talos.dev/?arch=amd64&cmdline-set=true&extensions=-&extensions=siderolabs%2Fqemu-guest-agent&platform=nocloud&target=cloud&version=1.10.6

For images and upgrades
    ```factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.10.6```

## Build VM's
- ControlPlane - 2x2 with guest agent (x3)
- Worker node - 4x16 with guest agent (x2)

## Install Control Plane

You need to build the control plane nodes, then add Cilium since we've turned off kube-proxy from Talos

### First Controlplane node
```
bootcp.bat <IP>
```

***Wait for a few pods to spin up***

### Install Cilium 

```
helm install cilium cilium/cilium --namespace kube-system -f cilium.yaml
```

<!-- ORIG
```
helm install `
    cilium `
    cilium/cilium `
    --namespace kube-system `
    --set=ipam.mode=kubernetes `
    --set=kubeProxyReplacement=true `
    --set=securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" `
    --set=securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" `
    --set=cgroup.autoMount.enabled=false `
    --set=cgroup.hostRoot=/sys/fs/cgroup `
    --set=k8sServiceHost=localhost `
    --set=k8sServicePort=7445 `
    --set=gatewayAPI.enabled=false `
    --set=gatewayAPI.enableAlpn=true `
    --set=gatewayAPI.enableAppProtocol=true `
    --set l2announcements.enabled=true `
    --set externalIPs.enabled=true
``` -->

**Notes**
- Watch for pods to spin up.  Since only one CP is alive, the other Cillium-operator won't start, that's OK.
- Metrics server won't start either since we don't have any worker nodes

Restart Cilium since it was installed after Talos
```
kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart ds/cilium
```

Cilium L2Announce (ARP)
```
kubectl apply -f cilium-announce.yaml
```

Cilium ippool
```
kubectl apply -f cilium-ippool.yaml
```

### Additional ControlPlane nodes
```
addrole.bat <ip> controlplane.yaml 
```

## Worker nodes
```
addrole.bat <ip> worker.yaml
```

## Traefik Gateway API
https://doc.traefik.io/traefik/routing/providers/kubernetes-gateway/#traefik-kubernetes-with-gateway-api

### Namespace + Traefik + Gateway 
```
kubectl apply -f traefik-namespace.yaml
helm install traefik traefik/traefik -f .\traefik.yaml -n traefik
kubectl apply -f traefik-gateway.yaml
```
This will create a Traefik load balancer service which is where the gateway will connect

https://github.com/traefik/traefik-helm-chart/blob/master/traefik/VALUES.md


## NFS Storage
```
helm install nfs-storage nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --namespace kube-system -f nfs.yaml
```

<!-- ORIG
```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner 

helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner `
    --set nfs.server=192.168.100.50 `
    --set nfs.path=/mnt/bcache0 `
    --set storageClass.name=nfs `
    --namespace kube-system `
    --set storageClass.defaultClass=true `
    --set storageClass.archiveOnDelete=false
``` -->


## Cert-manager
See Cert-Manager folder for instructions

## Postgres Operator
See postgres-zalando folder
