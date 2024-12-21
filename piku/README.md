# PIKU HTTP / HTTPS enpoints going through K3s Traefik

Provide a way to get HTTP/HTTPS traffic through the Edgerouter into an internal VM instead of terminating on Kubernetes (K3s)

```Internet -> EdgeRouter -> K3s Master with LB (192.168.100.140) -> Piku VM (192.168.100.x)```

Use kubernetes Endpoints (not endpointslices)

Basically, define a service and endpoint, and point the ingress to the endpoint.  The added benefit is that certmanager can be used to get an SSL cert instead of the VM behind the scenes.

## How - Service + EndPoints + Ingress (HTTP/HTTPS) - WORKING (9/24/23)
- Service.yaml  
- Endpoint.yaml
- (some ingress file)

The ingress.yaml file has the unique URL per application.  The service.yaml and endpoint.yaml are the same for all apps, all traffic is sent to the VM

## Resources
BEST ONE HERE - Kris is a genius - https://kristhecodingunicorn.com/post/k8s_proxy_svc/

https://kubernetes.io/docs/concepts/services-networking/endpoint-slices/  
https://stackoverflow.com/questions/52857825/what-is-an-endpoint-in-kubernetes

