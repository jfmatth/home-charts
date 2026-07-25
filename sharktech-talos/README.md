# Talos on SharkTech

**Architecture**
Sharktech 1x2, Ubuntu 25.10

``eth0`` = Public IP  
``eth1`` = Private VNET (192.168.50.0/24) 192.168.50.1 (DGW)

## Prerequisits
Talos
```
curl -sL https://talos.dev/install | sh
```

Helm
```
wget https://get.helm.sh/helm-v4.2.3-linux-amd64.tar.gz && \
tar xvfz helm-v4.2.3-linux-amd64.tar.gz && \
sudo install linux-amd64/helm /usr/local/bin/
```

Cilium
```
helm repo add cilium https://helm.cilium.io/
helm repo update
```

Kubectl
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
sudo install kubectl /usr/local/bin && \
rm kubectl 
```

## IP Forwarding for DNAT to cluster
```
sudo nano /etc/sysctl.d/99-bastion.conf
```

```
net.ipv4.ip_forward=1
```

Apply
```
sudo sysctl --system
```

NAT and UFW
```
sudo nano /etc/default/ufw
```
Change ``DEFAULT_FORWARD_POLICY="ACCEPT"``

Add the following to the top of ``/etc/ufw/before.rules``
```
# NAT table rules
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]

# 1. DNAT rule: Forward port 80 to the private VM
-A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 192.168.50.10:80
-A PREROUTING -i eth0 -p tcp --dport 6443 -j DNAT --to-destination 192.168.50.10:6443

# 2. Your existing Masquerade rule (keep this)
-A POSTROUTING -o eth0 -j MASQUERADE

# Force return traffic by masquerading inbound DNAT traffic
-A POSTROUTING -d 192.168.50.10 -p tcp --dport 80 -j MASQUERADE
-A POSTROUTING -d 192.168.50.10 -p tcp --dport 6443 -j MASQUERADE

# Commit the changes
COMMIT
```

UFW Rule changes
```
sudo ufw route allow proto tcp to 192.168.50.10 port 80
sudo ufw reload
```

## Talos

### Control Plane
Provision a Talos Control Planeon the vNetLAS network

- 2X4 vm
- Talos 1.13.5 template
- Admin name / password don't matter
- No public IP
- Private network, 192.168.50.10

From the public VM...  

Following the instructions here - https://docs.siderolabs.com/talos/v1.13/getting-started/getting-started#step-3-store-your-node-ip-addresses-in-a-variable

```
export CONTROL_PLANE_IP=192.168.50.10
export CLUSTER_NAME=talos-sharktech
export DISK_NAME=sda
talosctl gen config $CLUSTER_NAME https://$CONTROL_PLANE_IP:6443 \
    --install-disk /dev/$DISK_NAME \
    --config-patch-control-plane @cp-patch-network.yaml \
    --config-patch @cp-patch-sans.yaml \
    --force
```

Apply the config to the running VM
```
talosctl apply-config --insecure \
    --nodes $CONTROL_PLANE_IP \
    --file controlplane.yaml
```

Save all context stuff
```
talosctl config add talos-sharktech
cp talosconfig ~/.talos/config
talosctl config endpoint $CONTROL_PLANE_IP
talosctl config node $CONTROL_PLANE_IP
talosctl config contexts
talosctl kubeconfig -f ~/.kube/config
```


Endpoints / bootstrap / dashboard / healthcheck
```
talosctl --talosconfig=./talosconfig config endpoints $CONTROL_PLANE_IP
talosctl bootstrap --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig
talosctl dashboard --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig
talosctl --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig health
```

**Dashboard will show everything ready, except the cluster, you need to get Cilium installed**

Set Hostname
```
talosctl patch machineconfig --talosconfig=./talosconfig --nodes $CONTROL_PLANE_IP -p @cp-patch-hostname.yaml
```

<!-- Fix DNS - Use host DNS instead of ???
```
talosctl patch machineconfig -n 192.168.50.10 --patch @dns-fix-patch.yaml
``` -->

Cillium
```
helm install cilium cilium/cilium --namespace kube-system -f cilium-values.yaml --version 1.18.9
kubectl apply -f cilium-announce.yaml

```

### Traefik
https://docs.siderolabs.com/kubernetes-guides/advanced-guides/deploy-traefik#deploy-traefik-as-a-gateway-api

```
helm repo add traefik https://traefik.github.io/charts
helm repo update

```

```
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml
kubectl apply -f traefik-namespace.yaml
helm install traefik traefik/traefik -f traefik-values.yaml -n traefik
kubectl apply -f traefik-gateway.yaml
```

Metrics Server
```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system -f ./metrics-server.yaml
```

### Nodes

Node 1
```
talosctl apply-config --insecure --nodes 192.168.50.11 --file worker.yaml
talosctl patch machineconfig --talosconfig=./talosconfig --nodes 192.168.50.11 -p @nd1-patch-network.yaml
talosctl patch machineconfig --talosconfig=./talosconfig --nodes 192.168.50.11 -p @nd1-patch-hostname.yaml
```

## Talos Upgrades
Current Sharktech template is v1.13.5

Upgrade to 1.13.6 via https://docs.siderolabs.com/talos/v1.13/configure-your-talos-cluster/lifecycle-management/upgrading-talos#upgrade-api-changes-in-talos-v1-13

```
talosctl upgrade --nodes 192.168.50.10 --reboot-mode force
```

## Talos resets on ST
```
talosctl reset --system-labels-to-wipe EPHEMERAL,STATE --reboot --graceful=false -n %1
```