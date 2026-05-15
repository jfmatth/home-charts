
```
kubectl run pg-shell --rm -i --tty --image=postgres:latest -- /bin/bash
```

```
pgbench -i -s 50 $uri
```