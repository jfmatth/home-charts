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

## K3s install

### make sure SSH key is available on client machine connecting via SSH
```
eval `ssh-agent`
ssh-add 
```

### Install master and all nodes - Using  https://github.com/alexellis/k3sup#create-a-multi-master-ha-setup-with-embedded-etcd

```
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

## Longhorn install 
https://longhorn.io/docs/1.4.0/deploy/install/install-with-helm/

- Label nodes to hold storage  
    ```
    kubectl label nodes k3s-master node.longhorn.io/create-default-disk=true
    kubectl label nodes k3s-node-4 node.longhorn.io/create-default-disk=true
    kubectl label nodes k3s-master-2 node.longhorn.io/create-default-disk=true
    ```

- Install longhorn via Helm  
    ```
    helm repo add longhorn https://charts.longhorn.io
    helm repo update

    helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.4.0 --values values-longhorn.yaml
    ```

    Changes made to the values file:
    1. defaultSettings.createDefaultDiskLabeledNodes: true  
        This tells longhorn to only use storage on labeled nodes.  
        
        To label a node, use the following:  
        ```kubectl label nodes <node> node.longhorn.io/create-default-disk=true```

    2. defaultSettings.defaultReplicaCount: 2  
        Should be obvious, only keep 2 replicas of data.  We do this since we only have two physical machines with SSD, the rest are VM's.

