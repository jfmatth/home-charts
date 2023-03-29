eval `ssh-agent`
ssh-add

source ./servers.sh

ssh $NODE3_IP 'sudo reboot'
ssh $NODE2_IP 'sudo reboot'
ssh $NODE1_IP 'sudo reboot'
ssh $MASTER3_IP 'sudo reboot'
ssh $MASTER2_IP 'sudo reboot'
ssh $MASTER1_IP 'sudo reboot'

killall ssh-agent