# Installation

https://github.com/alexellis/k3sup#download-k3sup-tldr

```
curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/

k3sup --help
```
Make sure to validate the pre-requisits are done on each node

## Home Systems

Master = Lenovo M910Q - 8gb, 128GB, i5  https://www.2ndgear.com/lenovo/lenovo-thinkcentre-m910q-tiny/  - 192.168.100.52

### Node configuration (via **cloud-init and Ansible eventually**)

1. SUDO
    Tell sudoers to allow sudo without password
    ```
    %sudo   ALL=(ALL:ALL) NOPASSWD: ALL
    ```

2. open-vm-tools
    ```
    sudo apt-get install open-vm-tools -y
    sudo systemctl enable open-vm-tools --now
    ```

3. Future - Remove IPv6

4. Future - Update apt packages

## [K3s install](https://github.com/alexellis/k3sup#create-a-multi-master-ha-setup-with-embedded-etcd)

Install order: Master1, Master2, Master3, Node1, Node2  

```
eval `ssh-agent`
ssh-add

export VER=v1.25.5+k3s1
export USER=jfmatth
export MASTER1_IP=192.168.100.52
export MASTER2_IP=192.168.100.51
export MASTER3_IP=192.168.100.56
export NODE1_IP=192.168.100.53
export NODE2_IP=192.168.100.54

k3sup install \
  --ip $MASTER1_IP \
  --user $USER \
  --cluster \
  --local-path ~/.kube/config \
  --context default \
  --k3s-extra-args '--disable local-storage' \
  --k3s-version $VER
  
k3sup ready \
  --context default  \
  --kubeconfig ~/.kube/config

k3sup join \
  --ip $MASTER2_IP \
  --user $USER \
  --server \
  --server-ip $MASTER1_IP \
  --server-user $USER \
  --k3s-extra-args '--disable local-storage' \
  --k3s-version $VER

k3sup join \
  --ip $MASTER3_IP \
  --user $USER \
  --server \
  --server-ip $MASTER1_IP \
  --server-user $USER \
  --k3s-extra-args '--disable local-storage' \
  --k3s-version $VER

k3sup join \
  --ip $NODE1_IP \
  --server-ip $MASTER1_IP \
  --user $USER \
  --k3s-version $VER

k3sup join \
  --ip $NODE2_IP \
  --server-ip $MASTER_IP \
  --user $USER \
  --k3s-version $VER

k get nodes -o wide
```

## [Longhorn install](https://longhorn.io/docs/1.4.0/deploy/install/install-with-helm/)

- Label nodes to hold storage  
```
kubectl label nodes k3s-node-4    node.longhorn.io/create-default-disk=true
kubectl label nodes k3s-master-1v node.longhorn.io/create-default-disk=true
kubectl label nodes k3s-master-2v node.longhorn.io/create-default-disk=true
```

- Install longhorn via Helm  
The values file has two settings changed:  
  - createDefaultDiskLabeledNodes: true  - Only put volumes on labeled nodes
  - defaultReplicaCount: 2 - Change the replica count to 2


```
helm repo add longhorn https://charts.longhorn.io
helm repo update

helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.4.0 --values values-longhorn.yaml --atomic
```

## Uninstall

- Remove Longhorn 

Have to set the uninstall flag to true first in the settings  

```
kubectl -n longhorn-system edit settings.longhorn.io deleting-confirmation-flag
helm uninstall longhorn -n longhorn-system
```

- Remove K3s (in reverse order from install)  
```
eval `ssh-agent`
ssh-add

export MASTER1_IP=192.168.100.52
export MASTER2_IP=192.168.100.51
export MASTER3_IP=192.168.100.56

export NODE1_IP=192.168.100.53
export NODE2_IP=192.168.100.54

ssh $NODE2_IP 'k3s-agent-uninstall.sh'
ssh $NODE1_IP 'k3s-agent-uninstall.sh'
ssh $MASTER3_IP 'k3s-uninstall.sh'
ssh $MASTER2_IP 'k3s-uninstall.sh'
ssh $MASTER1_IP 'k3s-uninstall.sh'
```


