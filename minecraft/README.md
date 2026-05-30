# Setting up Minecraft on my Talos Cluster

https://github.com/itzg/minecraft-server-charts

## Talos configs

### Setup in Traefik in Talos
Need to enable the experimental channel in Traefik, which should be done when installing Traefik helm chart
https://doc.traefik.io/traefik/reference/routing-configuration/kubernetes/gateway-api/#tcp

### Patch controlplanes to allow nodeport ranges for Minecraft
https://oneuptime.com/blog/post/2026-03-03-configure-nodeport-range-in-talos-linux/view

from talos folder and for each controlplane node
```
talosctl -n <CONTROLPLANE_IP> patch machineconfig --patch @talos-noderange-patch.yaml
```

## ITZG Charts for Minecraft
DAMM, this guy makes everything!
```
helm repo add itzg https://itzg.github.io/minecraft-server-charts/
kubectl apply -f minecraft-namespace.yaml
```

### Install mc-router
```
helm install mc-router itzg/mc-router -f mcrouter-values.yaml
```

### Add TCPRoute for mc-router
```
k apply -f minecraft-tcproute.yaml
```

### Minecraft server #1
```
helm install minecraft `
  --set minecraftServer.eula=true `
  -f minecraft-values.yaml `
  itzg/minecraft
```


## Unifi port / hairpin changes

### DNS record (Amazon S3)
```
minecraft.3756home.org -> edge.3756home.org
```





# References

https://deepwiki.com/itzg/mc-router/8.2-kubernetes-deployment#debug-logging

https://help.uisp.com/hc/en-us/articles/22591184776983-EdgeRouter-Hairpin-NAT