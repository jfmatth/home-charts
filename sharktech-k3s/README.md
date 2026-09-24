# K3s on SharkTech

## host
**Architecture**
Sharktech 4x8, Ubuntu 25.10

``eth0`` = Public IP  

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
net.ipv4.ip_forward = 1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```

```
sudo sysctl --system
```

## Datadog install

Goto the Linux Install agent page
https://us5.datadoghq.com/fleet/install-agent/latest?platform=linux

After install you need to do the following:
- Adjust so logs are captured  
    ``datadog.yaml``
    ```
    logs_enabled: true
    ```
- Add datadog to the systemd-journal group
    ```
    sudo usermod -a -G systemd-journal dd-agent
    ```    
- Enable journald entries and disable datadog-agent logs  
    ``/etc/datadog/conf.d/journald.d/conf.yaml``
    ```
    logs:
    - type: journald
        container_mode: true
        
        exclude_units:
        - datadog-agent.service
    ```
<!-- - Create UFW logging
    ```
    sudo -u dd-agent mkdir /etc/datadog/config.d/ufw.d
    sudo nano /etc/datadog/config.d/ufw.d/conf.yaml
    ```
    ```
    logs:
      - type: file
        path: /var/log/ufw.log
        service: ufw
        source: ufw
        pipeline: ufw-pipeline
    ``` -->
- Restart the datadog agent
    ```
    sudo systemctl restart datadog-agent
    ```

## K3s install
- Turn off firewall blocking
```
sudo sed -i 's/^DEFAULT_FORWARD_POLICY=.*/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
sudo ufw reload
```

- Create a config.yaml file
```
sudo mkdir -p /etc/rancher/k3s
sudo nano /etc/rancher/k3s/config.yaml
```
```
disable:
- local-storage
- metrics-server

write-kubeconfig-mode: "0644"
write-kubeconfig "/home/jfmatth/.kube/config"

tls-san:
- "k8s.3756home.org"
```

- Install
```
curl -sfL https://get.k3s.io | sh -
```

### Datadog for k3s
- Install Helm
```
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash
```

- Datadog Operator
https://us5.datadoghq.com/fleet/install-agent/latest?platform=kubernetes


