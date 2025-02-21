eval `ssh-agent`
ssh-add

source ./prod-servers.sh

ssh $NODE3_IP 'k3s-killall.sh'
ssh $NODE2_IP 'k3s-killall.sh'
ssh $NODE1_IP 'k3s-killall.sh'
ssh $MASTER3_IP 'k3s-killall.sh'
ssh $MASTER2_IP 'k3s-killall.sh'
ssh $MASTER1_IP 'k3s-killall.sh'

killall ssh-agent
