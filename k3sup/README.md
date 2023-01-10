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
export SERVER_IP=192.168.100.52
export USER=jfmatth
export NODE1_IP=192.168.100.51

k3sup install --ip $SERVER_IP --user $USER --local-path ~/.kube/config --context default
k3sup ready --context default --kubeconfig ~/.kube/config
k3sup join --ip $NODE1_IP --server-ip $SERVER_IP --user $USER

k get nodes -o wide
```