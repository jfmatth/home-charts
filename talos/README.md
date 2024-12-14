# Building Talos-k8s (v1.84)

Our Cluster will have an API endpoint that is virtual, 192.168.100.130:6443, that is via the network changes below.  All nodes are DHCP which makes this easy.

The tough part was finding the ISO and target image for qemu guest agent features.

## Download the ISO with QEMU agent support
https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.8.4/nocloud-amd64.iso

## Build 5 VM's on Proxmox
2 x Control Plane  (2x2x32gb)  
3 x Worker Nodes   (4x8x3gb)

- Enable QEMU Guest
- Set disk to write-back cache
- Attach ISO ```talos-qemu-nocloud64.iso``` to VM's


## Use / Generate controlplane.yaml file with QEMU support
https://www.talos.dev/v1.8/talos-guides/install/virtualized-platforms/proxmox/#qemu-guest-agent-support

Got this line from here https://factory.talos.dev/?arch=amd64&cmdline-set=true&extensions=-&extensions=siderolabs%2Fqemu-guest-agent&platform=nocloud&target=cloud&version=1.8.4
```
talosctl gen config talos-k8s https://192.168.100.130:6443 --install-image factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.4 --force
```

### Change the network config to controlpanel.yaml

https://www.talos.dev/v1.8/talos-guides/network/vip/#configure-your-talos-machines
```
    network:
     interfaces:
      - deviceSelector:
          physical: true
        dhcp: true
        vip:
          ip: 192.168.100.130
```


## Add first node, need to know DHCP address
DHCP address may change after inital apply, check Proxmox
```
talosctl apply-config --insecure --nodes DHCP_ADDRESS_HERE --file controlplane.yaml
```

## Bootstrap Kubernetes
** Note ** - DHCP addresses change at home each reset of VM
```
talosctl --talosconfig=./talosconfig --nodes DHCP_ADDRESS_HERE bootstrap
```

## Add more control planes, they bootstrap automagically
```
talosctl apply-config --insecure --nodes DHCP_ADDRESS_HERE --file controlplane.yaml
```

## Add worker nodes, use worker.yaml file, they bootstrap automagically
```
talosctl apply-config --insecure --nodes DHCP_ADDRESS_HERE --file worker.yaml
```
