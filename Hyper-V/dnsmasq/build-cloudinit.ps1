$userData = @"
#cloud-config
package_update: true
packages:
  - dnsmasq

write_files:
  - path: /etc/netplan/01-static.yaml
    permissions: '0644'
    content: |
      network:
        version: 2
        ethernets:
          enp0s1:
            dhcp4: false
            addresses:
              - 10.10.10.2/24
            gateway4: 10.10.10.1
            nameservers:
              addresses:
                - 10.10.10.1
                - 1.1.1.1

  - path: /etc/dnsmasq.d/lab.conf
    permissions: '0644'
    content: |
      interface=enp0s1
      domain-needed
      bogus-priv
      no-resolv
      server=1.1.1.1
      server=8.8.8.8
      dhcp-range=10.10.10.50,10.10.10.150,12h
      dhcp-option=3,10.10.10.1
      dhcp-option=6,10.10.10.2

runcmd:
  - netplan apply
  - systemctl enable dnsmasq
  - systemctl restart dnsmasq
"@

$userData | Out-File -FilePath ".\user-data.yaml" -Encoding utf8
