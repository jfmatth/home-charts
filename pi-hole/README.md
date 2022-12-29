# MOVED 

This work has been moved to the flux2 home k3s repo https://github.com/jfmatth/fleet-home.git

**DO NOT FOLLOW THIS ONE**


## Helm Chart pi-hole install following [mojo2600](https://github.com/MoJo2600/pihole-kubernetes/tree/master/charts/pihole)

values.yaml - Values file for Helm install, Jeff's file is pretty old, so using website sample

## installation
```
helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
helm repo update

kubectl create namespace pihole

helm install --namespace pihole --values values.yaml  pihole mojo2600/pihole
```

## Notes

The values.yaml file sets the ServiceWeb to a LB IP, but no ingress

