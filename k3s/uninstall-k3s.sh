eval `ssh-agent`
ssh-add

source ./servers.sh

# if [-z $(NODE3_IP) ]; then ssh $NODE3_IP 'k3s-agent-uninstall.sh' ; fi
# if [-z $(NODE2_IP) ]; then ssh $NODE2_IP 'k3s-agent-uninstall.sh' ; fi
# if [-z $(NODE1_IP) ]; then ssh $NODE1_IP 'k3s-agent-uninstall.sh' ; fi
# if [-z $(MASTER3_IP) ]; then ssh $MASTER3_IP 'k3s-agent-uninstall.sh' ; fi
# if [-z $(MASTER2_IP) ]; then ssh $MASTER2_IP 'k3s-agent-uninstall.sh' ; fi
# if [-z $(MASTER1_IP) ]; then ssh $MASTER1_IP 'k3s-agent-uninstall.sh' ; fi
ssh $NODE3_IP 'k3s-agent-uninstall.sh'
ssh $NODE2_IP 'k3s-agent-uninstall.sh'
ssh $NODE1_IP 'k3s-agent-uninstall.sh'
# ssh $MASTER3_IP 'k3s-uninstall.sh'
# ssh $MASTER2_IP 'k3s-uninstall.sh'
ssh $MASTER1_IP 'k3s-uninstall.sh'

killall ssh-agent