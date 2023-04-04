eval `ssh-agent`
ssh-add

source ./servers.sh

# ssh $NODE5_IP 'k3s-agent-uninstall.sh'
# ssh $NODE4_IP 'k3s-agent-uninstall.sh'
# ssh $NODE3_IP 'k3s-agent-uninstall.sh'
# ssh $NODE2_IP 'k3s-agent-uninstall.sh'
# ssh $NODE1_IP 'k3s-agent-uninstall.sh'
ssh $MASTER3_IP 'k3s-uninstall.sh'
ssh $MASTER2_IP 'k3s-uninstall.sh'
ssh $MASTER1_IP 'k3s-uninstall.sh'

killall ssh-agent