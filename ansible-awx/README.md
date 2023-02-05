# AWX operator installation

https://github.com/ansible/awx-operator#helm-install-on-existing-cluster

```
helm repo add awx-operator https://ansible.github.io/awx-operator/
helm repo update
helm search repo awx-operator
helm install -n awx --create-namespace awx-operator awx-operator/awx-operator -n awx
```

# My instance
```
k create -f awx-instance.yaml -n awx
```
