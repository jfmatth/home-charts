# Building an dev environment for Sharktech

The goal is to have a lab with the following:
- Internal network (stLAB) for all VM's (192.168.50.0/24)
- Multipass VM with NIC's on both Default switch and new network

## Setup Switch, NAT and Network on Hyper-V host
**some items require Admin terminal**

This creates a new network on the host that allows the private 

- Create switch
    ```
    New-VMSwitch -Name stLAB -SwitchType Internal
    ```
- Static IP for Host (**Admin**)
    ```
    New-NetIPAddress `
    -InterfaceAlias "vEthernet (stLAB)" `
    -IPAddress 192.168.50.1 `
    -PrefixLength 24
    ```

## DNSMasq to help boot Talos ISO
```
multipass launch `
  --name dns-stlab `
  --network name=stLAB `
  --cloud-init .\dnsmasq.yaml `
  --memory 1024M `
  --disk 5G `
  --cpus 1 `
  26.04
```

## Build Bastion host

```
multipass launch `
  --name bastion `
  --network name=stLAB `
  --cloud-init .\talos=bastion.yaml `
  --memory 2G `
  --disk 20G `
  --cpus 1 `
  26.04
```



