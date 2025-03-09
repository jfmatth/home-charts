# Installation

https://argo-cd.readthedocs.io/en/stable/getting_started/

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

For now, we have to run an Load Balancer on another port for Traefik

Patch it for LB, then change the ports to 8080 and 4443 on the pods
```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

```
kubectl edit svc/argocd-server -n argocd
```

Login should then be 192.168.100.140:8080, this applies to the current K3s install