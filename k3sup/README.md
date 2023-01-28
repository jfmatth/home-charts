# Installation

https://github.com/alexellis/k3sup#download-k3sup-tldr

```
curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/

k3sup --help
```

Make sure to validate the pre-requisits are done on each node

## Layout at home

Master = Lenovo M910Q - 8gb, 128GB, i5  https://www.2ndgear.com/lenovo/lenovo-thinkcentre-m910q-tiny/  - 192.168.100.52

Node-1 = HP Laptop (temporary), replace at some point - 192.168.100.51
Node-2 = Lenovo M910Q - 16gb, 256GB, i5 https://www.2ndgear.com/lenovo/lenovo-thinkcentre-m910q-tiny/ - 192.168.100.53
(future) Node-3 = Lenovo M910Q - 16gb, 256GB, i5 https://www.2ndgear.com/lenovo/lenovo-thinkcentre-m910q-tiny/ - 192.168.100.54

## K3s install

### make sure SSH key is available
```
eval `ssh-agent`
ssh-add 
```

### Install master and all nodes
```
export VER=v1.25.5+k3s1
export MASTER_IP=192.168.100.52
export USER=jfmatth
export NODE1_IP=192.168.100.51
export NODE2_IP=192.168.100.54
export NODE3_IP=192.168.100.53

k3sup install --ip $MASTER_IP --user $USER --local-path ~/.kube/config --context default --k3s-extra-args '--disable local-storage' --k3s-version $VER
k3sup ready --context default --kubeconfig ~/.kube/config
k3sup join --ip $NODE1_IP --server-ip $MASTER_IP --user $USER --k3s-version $VER
k3sup join --ip $NODE2_IP --server-ip $MASTER_IP --user $USER --k3s-version $VER
k3sup join --ip $NODE3_IP --server-ip $MASTER_IP --user $USER --k3s-version $VER

k get nodes -o wide
```

## Longhorn install 
https://longhorn.io/docs/1.4.0/deploy/install/install-with-helm/

```
helm repo add longhorn https://charts.longhorn.io
helm repo update

helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.4.0
```
