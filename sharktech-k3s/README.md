# K3s on SharkTech

**Architecture**

- K3s Control-Plane x 1
    - 2x2
    - 2 NICs (public, private)
        - ``eth0`` = Public IP  
        - ``eth1`` = Private VNET (192.168.50.0/24) 192.168.50.1 (DGW)
    - NFS
         Sharktech 2x2x20, Ubuntu 25.10
    - K3s CP
- K3s Nodes x 2
    - 3 x 7
    - private NIC
    - K3s node
- K3sup for K3s install

# Build VM's

## Control Plane (k3s-cp-1)
### Sharktech
    - LOS / PublicIP / 1x2 / Private VLAN attached / Ubuntu 25.10 / jfmatth /keys
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
**Remove** all pre-generated sshd config files and create a file ``/etc/ssh/sshd_config.d/00-lockdown.conf``

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
  
### Un-attended updates (Security only)  **TODO**

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
sudo ufw allow 80
sudo ufw allow 443
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

### Datadog install

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

### JuiceFS
- See JuiceFS folder, sans the LXC stuff


## Node 1 and Node 2
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
### IP Stuff
```
sudo nano /etc/sysctl.d/99-node.conf
```

```
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```
```
sudo sysctl --system
```

### Datadog install

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

### NFS Common
used by NFS provisioner

```

sudo apt update
sudo apt install -y nfs-common
```

# K3s install

## K3sup
From k3sup install page
```
curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/
k3sup --help
```
My Install (from k3s-cp-1)
```
cpIP=192.168.50.1
node1=192.168.50.10
node2=192.168.50.20
user=jfmatth
k3sup install \
  --ip $cpIP \
  --user $user \
  --local-path ~/.kube/config \
  --context default \
  --k3s-extra-args '--disable local-storage,metrics-server,traefik --tls-san k8s.3756home.org --flannel-iface=eth1'

k3sup join \
  --ip $node1 \
  --server-ip $cpIP \
  --user $user

k3sup join \
  --ip $node2 \
  --server-ip $cpIP \
  --user $user
```

copy ~/.kube/config to local workstation and adjust IP to k8s.3756home.org

###  Traefik Gateway API (by k3s standards)
https://docs.k3s.io/networking/networking-services#gateway-api

As of Traefik, gateway CRD's need to be installed

Gateway CRD Standard
```
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
```
Gateway CRD Experimental (needed for Minecraft TCPRoute)  
```
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/experimental-install.yaml
```

Make sure LB only runs on the Control-Plane
```
kubectl label nodes k3s-cp-1 svccontroller.k3s.cattle.io/enablelb=true
kubectl taint node k3s-cp-1 node-role.kubernetes.io/control-plane=true:NoSchedule
```
Install via Helm, since it was disabled on k3s install
```
helm repo add traefik https://traefik.github.io/charts
helm repo update

kubectl apply -f traefik-namespace.yaml
helm install traefik traefik/traefik -f traefik-values.yaml -n traefik
kubectl apply -f traefik-gateway.yaml
```

### Metrics Server
```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system
```

### Datadog for k3s
- Datadog Operator
https://us5.datadoghq.com/fleet/install-agent/latest?platform=kubernetes

### Certmanager
- See certmanager folder

### NFS Storage (requires JuiceFS above)
https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner#with-helm

```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
helm install nfs-storage nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --namespace kube-system -f nfs-juice.yaml
```

### CloudNative Postgres
- See cloudnativepg 


<!-- 

## JuiceFS

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

*[Service]
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

 -->