# Postgres operator using Zalando https://github.com/zalando/postgres-operator


## Install operator and UI

**There is a bug in 1.10 now that doesn't let the UI work**

```
helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator 
helm repo add postgres-operator-ui-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator-ui
helm repo update


helm install postgres-operator postgres-operator-charts/postgres-operator \
    -n postgres \
    --create-namespace
    --values operator-values.yaml

helm install postgres-operator-ui postgres-operator-ui-charts/postgres-operator-ui \
    -n postgres \
    -f postgresUI-values.yaml \
    --version 1.9.0

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
