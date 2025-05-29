# Postgres operator using Zalando https://github.com/zalando/postgres-operator

### Notes:
- 5/20/2025 - Updated for powershell and Talos
- 6/15/2024 - v1.12.2 the UI works again. 


## Install operator and UI

```
helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator 
helm repo add postgres-operator-ui-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator-ui
helm repo update

helm install postgres-operator postgres-operator-charts/postgres-operator `
    -n postgres `
    --create-namespace `
    --values operator-values.yaml 

helm install postgres-operator-ui postgres-operator-ui-charts/postgres-operator-ui `
    -n postgres `
    -f postgresUI-values.yaml

```
## Upgrade the operator
```
helm upgrade postgres-operator postgres-operator-charts/postgres-operator `
    -n postgres `
    --reuse-values

helm upgrade postgres-operator-ui postgres-operator-ui-charts/postgres-operator-ui `
    -n postgres `
    --reuse-values
```

## Sample DB

```
apiVersion: "acid.zalan.do/v1"
kind: postgresql
metadata:
  name: pg-minimal-cluster
spec:
  teamId: "acid"
  volume:
    size: 1Gi
  numberOfInstances: 2
  users:
    zalando:  # database owner
    - superuser
    - createdb
    foo_user: []  # role for application foo
  databases:
    foo: zalando  # dbname: owner
  preparedDatabases:
    bar: {}
  postgresql:
    version: "15"
```
