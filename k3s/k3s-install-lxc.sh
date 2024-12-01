eval `ssh-agent`
ssh-add

context=default-lxc
source ./prod-servers-lxc.sh


echo "Installing Master1 $MASTER1_IP"
k3sup install \
  --ip $MASTER1_IP \
  --user $USER \
  --local-path ~/.kube/config \
  --context $context \
  --merge \
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

echo "Joining node3 $NODE4_IP"
k3sup join \
  --ip $NODE4_IP \
  --server-ip $MASTER1_IP \
  --user $USER \
  --k3s-version $VER

kubectl get nodes -o wide

killall ssh-agent