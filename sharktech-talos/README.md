# Talos on SharkTech

## Bastion host
**Architecture**
Sharktech 1x2, Ubuntu 25.10

``eth0`` = Public IP  
``eth1`` = Private VNET (192.168.50.0/24) 192.168.50.1 (DGW)

### UFW
```
sudo ufw enable
sudo ufw allow ssh
sudo ufw logging low
```
### SSH

Lockdown  
```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```
``sudo systemctl reload sshd``

Check Journalctl ``journalctl -f``

### Install software

Talos / Kubectl / helm / cilium
```
curl -sL https://talos.dev/install | sh
wget https://get.helm.sh/helm-v4.2.3-linux-amd64.tar.gz && \
    tar xvfz helm-v4.2.3-linux-amd64.tar.gz && \
    sudo install linux-amd64/helm /usr/local/bin/
helm repo add cilium https://helm.cilium.io/
helm repo update
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    sudo install kubectl /usr/local/bin && \
    rm kubectl 
```

### UFW Changes: Fowarding, DNAT and masquerading

IPv4 Forwarding
```
sudo nano /etc/sysctl.d/99-bastion.conf
net.ipv4.ip_forward=1
sudo sysctl --system
```

Change forward policy default
```
sudo sed -i 's/^DEFAULT_FORWARD_POLICY=".*"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
```

Add the following to the top of ``/etc/ufw/before.rules`` before the ``*filter`` section
```
# NAT table rules
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]

# 1. DNAT rule: Forward port 80 to the private VM
-A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 192.168.50.10:80
-A PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to-destination 192.168.50.10:443
-A PREROUTING -i eth0 -p tcp --dport 6443 -j DNAT --to-destination 192.168.50.10:6443

# 2. Your existing Masquerade rule (keep this)
-A POSTROUTING -o eth0 -j MASQUERADE

# Force return traffic by masquerading inbound DNAT traffic
-A POSTROUTING -d 192.168.50.10 -p tcp --dport 80 -j MASQUERADE
-A POSTROUTING -d 192.168.50.10 -p tcp --dport 443 -j MASQUERADE
-A POSTROUTING -d 192.168.50.10 -p tcp --dport 6443 -j MASQUERADE

# Commit the changes
COMMIT
```

UFW Inbound
```
sudo ufw route allow proto tcp to 192.168.50.10 port 80
sudo ufw route allow proto tcp to 192.168.50.10 port 443
sudo ufw route allow proto tcp to 192.168.50.10 port 6443

sudo ufw route allow proto tcp from 192.168.50.10 port 80
sudo ufw route allow proto tcp from 192.168.50.10 port 443
sudo ufw route allow proto tcp from 192.168.50.10 port 6443

sudo ufw reload
```

## TalosLAS

8/2/26 - [Combine](https://docs.siderolabs.com/talos/v1.13/deploy-and-manage-workloads/workloads-on-controlplane#enable-workloads-on-your-control-plane-nodes) control + woker on single node, simpler and more cost effective


### Provision
Provision a Talos Control Plane on the vNetLAS network

- Max vm
- Talos 1.13.5 template
- Admin name / password don't matter
- No public IP
- Private network, 192.168.50.10/24, G/W 192.168.50.1

From the bastion host VM...  

Following the instructions [here](https://docs.siderolabs.com/talos/v1.13/getting-started/getting-started#step-3-store-your-node-ip-addresses-in-a-variable)

```
export CONTROL_PLANE_IP=192.168.50.10
export CLUSTER_NAME=talos-sharktech
export DISK_NAME=sda
talosctl gen config $CLUSTER_NAME https://$CONTROL_PLANE_IP:6443 \
    --install-disk /dev/$DISK_NAME \
    --config-patch-control-plane @cp-patch-all.yaml \
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
```

**Dashboard will show everything ready, except the cluster, you need to get Cilium installed**

### Cillium
```
helm install cilium cilium/cilium --namespace kube-system -f cilium-values.yaml --version 1.18.13
sleep 5
kubectl apply -f cilium-announce.yaml

```

Test cluster health
```
talosctl --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig health
```


### Traefik
https://docs.siderolabs.com/kubernetes-guides/advanced-guides/deploy-traefik#deploy-traefik-as-a-gateway-api

```
helm repo add traefik https://traefik.github.io/charts
helm repo update

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml
kubectl apply -f traefik-namespace.yaml
helm install traefik traefik/traefik -f traefik-values.yaml -n traefik
kubectl apply -f traefik-gateway.yaml
```

### Metrics Server
```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system -f ./metrics-server.yaml
```

### Cert-Manager
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl apply -f cert-manager-namespace.yaml
helm install cert-manager jetstack/cert-manager --namespace cert-manager  --create-namespace -f cert-manager.yaml
```

ClusterIssuer
```
kubectl apply -f cert-manager-clusterissuer.yaml
```
After Certmanager is installed, and everything working - the gateway should be programmed like below
```
kubectl get gateway -A
NAMESPACE   NAME              CLASS     ADDRESS           PROGRAMMED   AGE
traefik     traefik-gateway   traefik   192.168.100.140   True         6m28s
```

### DataDog
- Goto Datadog integration page https://us5.datadoghq.com/account/settings/agent/latest?platform=kubernetes
- Helm Chart not Operator
- Pick API Key, copy it to clipboard


Modify the default text below with the API key
```
helm repo add datadog https://helm.datadoghq.com
helm repo update
kubectl apply -f datadog-namespace.yaml
kubectl create secret generic datadog-secret --namespace=datadog --from-literal api-key=
```

Install the helm chart for Talos, not the operator
```
helm install datadog datadog/datadog -f datadog-values.yaml -n datadog
```

## whoami pulse site
Might be worth having a pulse site to reference, whoami does that

Follow README in whoami folder

## JuiceFS
We will setup Juice on the bastion box

Bucketname on Sharktech = ``juicefs-sharktech``

### Install v1.4x
```
curl -sSL https://d.juicefs.com/install | sh -

sudo mkdir -p /opt/juicefs
sudo juicefs format \
    --storage s3 \
    --bucket https://juicefs-sharktech.s3.lax.sharktech.net \
    --access-key <access-key here> \
    --secret-key <secret key here> \
    sqlite3:///opt/juicefs/myjfs.db \
    juicefs
```
Should see **``Volume is formated as ...``**

### Create systemd.service
```
sudo nano /etc/systemd/system/juicefs.service
```
```
[Unit]
Description=JuiceFS FUSE Mount
Before=nfs-server.service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/juicefs mount sqlite3:///opt/juicefs/myjfs.db /mnt/juicefs \
    --writeback \
    --o writeback_cache 
ExecStop=/bin/fusermount -u /mnt/juicefs
Restart=on-failure

[Install]
WantedBy=remote-fs.target
WantedBy=multi-user.target
```
## Enable and Start the services
```
systemctl enable juicefs.service --now
```

If no errors, check ```/mnt/juicefs``` exists

## NFS Server
```apt install nfs-kernel-server```

### Create NFS exports
Make folders under /mnt/juicefs

```
/mnt/juicefs/talos
```

update ```/etc/exports```
```
/mnt/juicefs/talos 192.168.50.0/24(rw,sync,no_subtree_check,fsid=2,no_root_squash)
```

### export NFS mounts
```
sudo exportfs -ra
```

## NFS Storage
https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner#with-helm

```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
helm install nfs-storage nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --namespace kube-system -f nfs-juice.yaml
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