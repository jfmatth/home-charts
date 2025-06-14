# Install

From https://github.com/stefanprodan/podinfo/tree/master/charts/podinfo

```
helm install podinfo podinfo/podinfo -f values.yaml -n podinfo
kubectl apply -f httproute.yaml -n podinfo
```

Verify
```
curl test.3756home.org/ -i
```