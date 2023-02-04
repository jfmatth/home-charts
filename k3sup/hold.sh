export VER=v1.25.5+k3s1
export MASTER_IP=192.168.100.52
export USER=jfmatth
export NODE1_IP=192.168.100.55

k3sup join --ip $NODE1_IP --server-ip $MASTER_IP --user $USER --k3s-version $VER

k get nodes -o wide