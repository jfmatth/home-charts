echo PGHOST=192.168.100.140
echo PGPORT=$(kubectl get svc/database -n postgres -o jsonpath={.spec.ports[0].nodePort} )
echo PGDATABASE=$1
echo PGMASTER=$(kubectl get pods -o jsonpath={.items..metadata.name} -l application=spilo,cluster-name=database,spilo-role=master -n postgres)
echo PGUSER=homedb
echo PGPASSWORD=$(kubectl get secret django.database -o 'jsonpath={.data.password}' -n postgres | base64 -d)