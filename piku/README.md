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

## Method 2 - Have HTTPS terminate via cert-manager at Ingress, and then pass traffic back to Piku HTTP - Working (9/24/23)

- service.yaml
- endpoint.yaml
- ingress.yaml

The ingress.yaml file has the unique settings per piku application.  The service.yaml and endpoint.yaml are the same for all apps, all traffic is sent to piku.