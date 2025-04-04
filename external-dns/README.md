# ExternalDNS using Digital Ocean
https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/digitalocean.md


## Create namespace
```
kubectl create namespace externaldns
```

## Create Secret from token
Get token from Onenote

```
kubectl create secret generic do-token --from-literal=DO-TOKEN=YOUR_DIGITALOCEAN_API_KEY -n externaldns
```

## deploy ExternalDNS via deployment
```
kubectl apply -f deployment.yaml
```