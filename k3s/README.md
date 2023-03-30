# K3s Home cluster

## [K3sup install](https://github.com/alexellis/k3sup#download-k3sup-tldr)

```
curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/

k3sup --help
```
Make sure to validate the pre-requisits are done on each node

## Node configuration

Currently running Centos8-Stream on ProxMox

- SUDO
    Tell sudoers to allow sudo without password
    ```
    %wheel   ALL=(ALL:ALL) NOPASSWD: ALL
    ```

- Copy SSH Keys to node (ssh-copy-id)


## Run Ansible playbook(s)

### k3s-configure.yaml
```
eval `ssh-agent`
ssh-add
ansible-playbook k3s-configure.yaml -i ansible-hosts.yaml -b
```

### K3s install playbook
https://github.com/PyratLabs/ansible-role-k3s/blob/main/documentation/quickstart-ha-cluster.md



## [Cluster install](https://github.com/alexellis/k3sup#create-a-multi-master-ha-setup-with-embedded-etcd)

Install order: Master1, Master2, Master3, Node1, Node2  

Run k3s-install.sh command
```
./k3s-install.sh
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
  - defaultSettings.createDefaultDiskLabeledNodes: true
  - defaultSettings.defaultReplicaCount: 3
  - longhornUI.replicas: 1
  - ingress.enabled: true
  - ingress.host: longhorn.192.168.100.51.nip.io
  - ingress.path: /

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

## Shutdown cluster
```
bash ./shutdown-k3s.sh
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
bash uninstall-k3s.sh
```