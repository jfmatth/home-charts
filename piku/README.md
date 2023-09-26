# PIKU HTTP / HTTPS enpoints going through K3s Traefik

Provide a way to get HTTP/HTTPS traffic through the Edgerouter into an internal VM instead of terminating on Kubernetes (K3s)

```Internet -> EdgeRouter -> Master (192.168.100.140) -> Piku VM (192.168.100.110)```

## Resources
BEST ONE HERE - Kris is a genius - https://kristhecodingunicorn.com/post/k8s_proxy_svc/

https://kubernetes.io/docs/concepts/services-networking/endpoint-slices/  
https://stackoverflow.com/questions/52857825/what-is-an-endpoint-in-kubernetes


## Method 1 - Service + EndPoints + Ingress (HTTP ONLY) - WORKING (9/24/23)
- Service.yaml  
- Endpoint.yaml
- Ingress.yaml

**Do not name the endpoint, won't work**

## Method 2 - Service + EndPointSlice + Ingress (HTTP ONLY)

## Method 3 - IngressRouteTCP from Traefik
https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/#kind-ingressroutetcp

- service.yaml
- endpoint.yaml
- ingressroutetcp.yaml

Not working yet :()


## Testing
Traefik has some info I'm working with ```https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/#configuration-examples```

### 

