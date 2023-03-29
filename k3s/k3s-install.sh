eval `ssh-agent`
ssh-add

source ./servers.sh

echo "Installing Master1 $MASTER1_IP"
k3sup install \
  --ip $MASTER1_IP \
  --user $USER \
  --cluster \
  --local-path ~/.kube/config \
  --context default \
  --k3s-extra-args '--disable local-storage' \
  --k3s-version $VER

echo "Validate cluster"
k3sup ready \
  --context default  \
  --kubeconfig ~/.kube/config

echo "Installing Master2 $MASTER2_IP"
k3sup join \
  --ip $MASTER2_IP \
  --user $USER \
  --server \
  --server-ip $MASTER1_IP \
  --server-user $USER \
  --k3s-extra-args '--disable local-storage' \
  --k3s-version $VER

echo "Installing Master3 $MASTER3_IP"
k3sup join \
  --ip $MASTER3_IP \
  --user $USER \
  --server \
  --server-ip $MASTER1_IP \
  --server-user $USER \
  --k3s-extra-args '--disable local-storage' \
  --k3s-version $VER

echo "Joining node1 $NODE1_IP"
k3sup join \
  --ip $NODE1_IP \
  --server-ip $MASTER1_IP \
  --user $USER \
  --k3s-version $VER

echo "Joining node2 $NODE2_IP"
k3sup join \
  --ip $NODE2_IP \
  --server-ip $MASTER1_IP \
  --user $USER \
  --k3s-version $VER

echo "Joining node3 $NODE3_IP"
k3sup join \
  --ip $NODE3_IP \
  --server-ip $MASTER1_IP \
  --user $USER \
  --k3s-version $VER

kubectl get nodes -o wide

killall ssh-agent