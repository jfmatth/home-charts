# K3s Home cluster

## [K3sup install](https://github.com/alexellis/k3sup#download-k3sup-tldr)

```
curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/

k3sup --help
```
Make sure to validate the pre-requisits are done on each node

### Node configuration (via **cloud-init and Ansible eventually**)

1. SUDO
    Tell sudoers to allow sudo without password
    ```
    %sudo   ALL=(ALL:ALL) NOPASSWD: ALL
    ```

2. qemu-guest-agent
    ```
    sudo apt-get install qemu-guest-agent -y
    ```

    reboot  

3. Future - Remove IPv6

4. Future - Update apt packages

5. Future - Remove multipathd service / socket

## [Cluster install](https://github.com/alexellis/k3sup#create-a-multi-master-ha-setup-with-embedded-etcd)

Install order: Master1, Master2, Master3, Node1, Node2  

Run k3s-install.sh command
```
sh k3s-install.sh
```

## [Longhorn install](https://longhorn.io/docs/1.4.0/deploy/install/install-with-helm/)

### Label nodes to hold storage  
```
kubectl label nodes k3s-master-1v node.longhorn.io/create-default-disk=true
kubectl label nodes k3s-master-2v node.longhorn.io/create-default-disk=true
kubectl label nodes k3s-master-3v node.longhorn.io/create-default-disk=true
```

### Install longhorn via Helm  
The values file has two settings changed:  
  - createDefaultDiskLabeledNodes: true  - Only put volumes on labeled nodes
  - defaultReplicaCount: 2 - Change the replica count to 2

```
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.4.0 --values values-longhorn.yaml --atomic
```

## [Service Load Balancer](https://docs.k3s.io/networking#service-load-balancer)
By default, K3s will put the load balancer on every node, but I only want it on the masters, so we'll need to add a label to the masters.

```
kubectl label nodes k3s-master-1v svccontroller.k3s.cattle.io/enablelb=true
kubectl label nodes k3s-master-2v svccontroller.k3s.cattle.io/enablelb=true
kubectl label nodes k3s-master-3v svccontroller.k3s.cattle.io/enablelb=true
```

## Uninstall cluster

### Remove Longhorn 

Have to set the uninstall flag to true first in the settings  

```
kubectl -n longhorn-system edit settings.longhorn.io deleting-confirmation-flag
helm uninstall longhorn -n longhorn-system
```

### Remove K3s (in reverse order from install)  

Use uninstall-k3s.sh  

```
sh uninstall-k3s.sh
```