PGHOST=192.168.100.140
PGPORT=$(kubectl get svc/database -n postgres -o jsonpath={.spec.ports[0].nodePort} )
PGDATABASE=$1
PGMASTER=$(kubectl get pods -o jsonpath={.items..metadata.name} -l application=spilo,cluster-name=database,spilo-role=master -n postgres)
PGUSER=homedb
PGPASSWORD=$(kubectl get secret homedb.database -o 'jsonpath={.data.password}' -n postgres | base64 -d)

echo $PGHOST
echo $PGPORT
echo $PGDATABASE
echo $PGMASTER
echo $PGUSER
echo $PGPASSWORD
echo DATABASE_URL=postgres://$PGUSER:$PGPASSWORD@192.168.100.140:30056/$PGDATABASE?ss