# Talos Omni build (at home)

## Requirements
- Omnictl
- Logged into Omni account
- Helm

    ### Cilium setup, pre-cluster build
    https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium#method-1-omni-manifest-sync

    ```
    helm repo add cilium https://helm.cilium.io/
    helm repo update
    helm template `
        cilium `
        cilium/cilium `
        --version 1.20.5 `
        --namespace kube-system `
        --values cilium-values.yaml > cilium.yaml
    ```

    ### Boot VM's for CP / WO

    - Boot VM's on Proxmox for CP and WO nodes
    - Label them in UI for various roles (role:controlplane or role:worker)

## Create cluster
- Build the machine classes specific to us
    ```
    omnictl apply -f machine-class.yaml
    ```

- Build the cluster, **make sure the VM's are labeled in Omni machines**
    ```
    omnictl cluster template sync --file omni-cluster.yaml
    ```
    Cluster takes ~5m to fully boot

- Download kubeconfig
    ```
    omnictl kubeconfig --cluster <cluster-name>
    ```

After cluster is created, Cilium is installed on the nodes and working!

Remove ISO from each VM

## Cilium L2 / Pool
Need to setup an IP Pool and what nodes answer to LoadBalancer types
```
kubectl apply -f cilium-announce.yaml
kubectl apply -f cilium-ippool.yaml
```

## Traefik
https://github.com/traefik/traefik-helm-chart/tree/master

### Gateway CRD's
As of Traefik, gateway CRD's need to be installed

<!-- Standard
```
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/standard-install.yaml
``` -->
Experimental (needed for Minecraft TCPRoute)
```
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/experimental-install.yaml
```

### Traefik install
```
kubectl apply -f traefik-namespace.yaml
helm install traefik traefik/traefik -f .\traefik.yaml -n traefik
kubectl apply -f traefik-gateway.yaml
```
This will create a Traefik load balancer service which is where the gateway will connect
- References  
https://github.com/traefik/traefik-helm-chart/blob/master/traefik/VALUES.md
https://doc.traefik.io/traefik/setup/kubernetes/#prepare-helm-chart-configuration-values  
https://doc.traefik.io/traefik/routing/providers/kubernetes-gateway/#traefik-kubernetes-with-gateway-api  


## NFS Storage https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner
```
helm install nfs-storage nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --namespace kube-system -f nfs.yaml
```
Cluster takes ~5m to fully boot

## Cert-manager
```
kubectl apply -f cert-manager-namespace.yaml
helm install cert-manager jetstack/cert-manager --namespace cert-manager  --create-namespace -f cert-manager.yaml
```

### Add ClusterIssuer
```
kubectl apply -f cert-manager-clusterissuer.yaml
```
After Certmanager is installed, and everything working - the gateway should be programmed like below
```
kubectl get gateway -A
NAMESPACE   NAME              CLASS     ADDRESS           PROGRAMMED   AGE
traefik     traefik-gateway   traefik   192.168.100.140   True         6m28s
```
### References
https://cert-manager.io/docs/configuration/acme/http01/#configuring-the-http-01-gateway-api-solver  
https://cert-manager.io/docs/installation/helm/#installing-cert-manager  

### Traefik install
```
kubectl apply -f traefik-namespace.yaml
helm install traefik traefik/traefik -f .\traefik.yaml -n traefik
kubectl apply -f traefik-gateway.yaml
```
This will create a Traefik load balancer service which is where the gateway will connect
- References  
https://github.com/traefik/traefik-helm-chart/blob/master/traefik/VALUES.md
https://doc.traefik.io/traefik/setup/kubernetes/#prepare-helm-chart-configuration-values  
https://doc.traefik.io/traefik/routing/providers/kubernetes-gateway/#traefik-kubernetes-with-gateway-api  

## Postgres Operator
See cloudnativepg folder for installation
