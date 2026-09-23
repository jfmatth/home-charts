# K3s on SharkTech

## host
**Architecture**
Sharktech 4x8, Ubuntu 25.10

``eth0`` = Public IP  

- you should do a release upgrade to 26.10 ``do-release-upgrade``


### UFW
```
sudo ufw enable
sudo ufw allow ssh
sudo ufw logging low
```
### SSH

**Remove** all pre-generated sshd config files in ``/etc/ssh/sshd_config.d/``.  

Create a file ``/etc/ssh/sshd_config.d/00-lockdown.conf
```
sudo rm /etc/ssh/sshd_config.d/*
sudo nano /etc/ssh/sshd_config.d/00-lockdown.conf
```

```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes

AllowUsers john jfmatth
```
``sudo systemctl reload sshd``

Check Journalctl ``journalctl -f``.  You should see a lot of denied logings with [preauth]

### Remove un-needed services
```
sudo systemctl disable multipathd.service --now
sudo systemctl disable ModemManager.service --now
```

### Un-attended updates (Security only)

### Network 

IPv4 Forwarding / Diable IPv6
```
sudo nano /etc/sysctl.d/99-bastion.conf
```

```
net.ipv4.ip_forward=1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```

```
sudo sysctl --system
```
