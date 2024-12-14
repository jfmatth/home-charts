# Building Talos-k8s (v1.84)

## controlpanel.yaml
Only modifications for controlplane.yaml are below

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

### Add first node, need to know DHCP address
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
