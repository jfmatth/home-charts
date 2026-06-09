# CloudnativePG - Cloud Native PostgresSQL v1.29.1

https://cloudnative-pg.io/docs/1.29/quickstart

## Install via CRD
```
kubectl apply --server-side -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.29/releases/cnpg-1.29.1.yaml
```

This installs the operator and waits for clusters.

## Example Cluster
```
kubectl apply -f cluster-example.yaml
```

Creates the following:
- Secrets for (default) app DB
- Services for R/W, R/O, R

## Benchmarking
If after the cluster is up, you want to do a little benchmarking, that's easy

1. Get the secrets into the cluster for access, use decoder.ps1 for this
    ```
    Get-KubeSecret cluster-example-app
    ```
    Copy the ```uri``` value for Step 3

2. Run a POD with pgBench
    ```
    kubectl run pg-shell --rm -i --tty --image=postgres:latest -- /bin/bash
    ```

3. Export URI, Setup pgBench and run the benchmark
    ```
    export uri=
    pgbench -i -s 50 $uri
    pgbench ...
    ```
https://pgbench.com/tutorials/
### Setup
```
export uri=
pgbench -i -s 50 $uri
```
### R/O Benchmark
These can use the SVC for r/o for better througput

For this, change the uri portion from ```example-rw.default``` to ```example-r.default```

```
pgbench --protocol=prepared --builtin=select -n -c 1 -j 1 -T 30 -P 5 $uri
pgbench --protocol=prepared --builtin=select -n -c 4 -j 2 -T 60 -P 5 $uri
pgbench --protocol=prepared --builtin=select -n -c 8 -j 4 -T 60 -P 5 $uri
pgbench --protocol=prepared --builtin=select -n -c 16 -j 4 -T 60 -P 5 $uri
```

### R/W Benchmark
Make sure the URI is -rw
```
pgbench --builtin=simple-update --protocol=prepared -c 8 -j 4 -T 60 -P 5 $uri
pgbench --builtin=simple-update --protocol=prepared -c 16 -j 4 -T 60 -P 5 $uri
```
