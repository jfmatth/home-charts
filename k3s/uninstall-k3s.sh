eval `ssh-agent`
ssh-add

export MASTER1_IP=192.168.100.52
export MASTER2_IP=192.168.100.51
export MASTER3_IP=192.168.100.56
export NODE1_IP=192.168.100.53
export NODE2_IP=192.168.100.54

ssh $NODE2_IP 'k3s-agent-uninstall.sh'
ssh $NODE1_IP 'k3s-agent-uninstall.sh'
ssh $MASTER3_IP 'k3s-uninstall.sh'
ssh $MASTER2_IP 'k3s-uninstall.sh'
ssh $MASTER1_IP 'k3s-uninstall.sh'

killall ssh-agent