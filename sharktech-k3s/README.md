# K3s on SharkTech

**Architecture**

- K3s Control-Plane
    - 2x2
    - 2 NICs (public, private)
        - ``eth0`` = Public IP  
        - ``eth1`` = Private VNET (192.168.50.0/24) 192.168.50.1 (DGW)

    - NFS
    -  Sharktech 2x2x20, Ubuntu 25.10
    - K3s CP
    - tainted for kube workloads only + LB / Gateway

- K3s Nodes x 2
    - 3 x 7
    - private NIC
    - K3s node

## Control Plane / Router

- Wait for updates to complete
- Remove the default route from the netplan file that was created, due to the DGW on the vlan
    - Remove the default route on eth1
    ```
    sudo nano /etc/netplan/50-cloud-init.yaml
    sudo netplan apply
    ping google.com
    ```
- Since it couldn't reach the net for updates, you need to update the system first
```
sudo apt-get update && sudo apt-get upgrade -y
```


### SSH

**Remove** all pre-generated sshd config files in ``/etc/ssh/sshd_config.d/``.  

Create a file ``/etc/ssh/sshd_config.d/00-lockdown.conf
```
sudo rm /etc/ssh/sshd_config.d/*
sudo nano /etc/ssh/sshd_config.d/00-lockdown.conf
```

```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes

AllowUsers john jfmatth
```
```
sudo systemctl reload sshd
```
Check Journalctl ``journalctl -f``.  You should see a lot of denied logings with [preauth]

### Remove un-needed services
```
sudo systemctl disable multipathd.service --now
sudo systemctl disable ModemManager.service --now
```
### Un-attended updates (Security only)

### Network 

IPv4 Forwarding / Diable IPv6
```
sudo nano /etc/sysctl.d/99-bastion.conf
```

```
net.ipv4.ip_forward = 1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```
```
sudo sysctl --system
```
### UFW Changes
- Enable UFW
```
sudo ufw enable
sudo ufw logging low
sudo ufw allow ssh
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow in on eth1
sudo ufw allow out on eth0
sudo ufw route allow in on eth1 out on eth0
sudo ufw route allow in on eth0 out on eth1
sudo ufw allow 6443/tcp #apiserver
sudo ufw allow from 10.42.0.0/16 to any #pods
sudo ufw allow from 10.43.0.0/16 to any #services
```

- Edit rules
```
sudo nano /etc/ufw/before.rules
```
```
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 192.168.50.0/24 -o eth0 -j MASQUERADE
COMMIT
```
```
sudo ufw reload
```

## Datadog install

Goto the Linux Install agent page
https://us5.datadoghq.com/fleet/install-agent/latest?platform=linux

After install you need to do the following:
- Adjust so logs are captured  
    ``datadog.yaml``
    ```
    logs_enabled: true
    ```
- Add datadog to the systemd-journal group
    ```
    sudo usermod -a -G systemd-journal dd-agent
    ```    
- Enable journald entries and disable datadog-agent logs  
    ``/etc/datadog-agent/conf.d/journald.d/conf.yaml``
    ```
    logs:
    - type: journald
        container_mode: true
        exclude_units:
        - datadog-agent.service
    ```

- Restart the datadog agent
    ```
    sudo systemctl restart datadog-agent
    ```

## Juice / NFS install - See below


## K3s install
<!-- - Turn off firewall blocking
```
sudo sed -i 's/^DEFAULT_FORWARD_POLICY=.*/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
sudo ufw reload
``` -->

- Create a config.yaml file
```
sudo mkdir -p /etc/rancher/k3s
sudo nano /etc/rancher/k3s/config.yaml
```
```
disable:
- local-storage
- metrics-server
- traefik

write-kubeconfig-mode: "0644"
write-kubeconfig: "/home/jfmatth/.kube/config"

node-ip: 192.168.50.1

tls-san:
- "k8s.3756home.org"
```

- Install
```
curl -sfL https://get.k3s.io | sh -
```

###  Traefik Gateway API (by k3s standards)
https://docs.k3s.io/networking/networking-services#gateway-api

As of Traefik, gateway CRD's need to be installed

Standard
```
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
```
Experimental (needed for Minecraft TCPRoute)  
```
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/experimental-install.yaml
```

```
helm repo add traefik https://traefik.github.io/charts
helm repo update

kubectl apply -f traefik-namespace.yaml
helm install traefik traefik/traefik -f traefik-values.yaml -n traefik
kubectl apply -f traefik-gateway.yaml
```

### NFS Storage
https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner#with-helm

```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
helm install nfs-storage nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --namespace kube-system -f nfs-juice.yaml
```


### Datadog for k3s
- Install Helm
```
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash
```

- Datadog Operator
https://us5.datadoghq.com/fleet/install-agent/latest?platform=kubernetes


## Certmanager
- See certmanager folder







## JuiceFS
We will setup Juice on the bastion box

Bucketname on Sharktech = ``juicefs-sharktech``

**Need Secret Keys**

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
sudo systemctl enable juicefs.service --now
```

If no errors, check ```/mnt/juicefs``` exists

## NFS Server
```sudo apt install nfs-kernel-server```

### Create NFS exports
Make folders under /mnt/juicefs

```
sudo mkdir -p /mnt/juicefs/sharktech
```

update ```/etc/exports```
```
/mnt/juicefs/sharktech 192.168.50.0/24(rw,sync,no_subtree_check,fsid=2,no_root_squash)
```

### export NFS mounts
```
sudo exportfs -ra
```

### Firewall rules (NFS v4)
```
sudo ufw allow in on eth1 from 192.168.50.10 to any port 2049 proto tcp
sudo ufw allow in on eth1 from 192.168.50.10 to any port 2049 proto udp
```

