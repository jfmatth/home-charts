# Talos under Hyper-V lab

**might need to run this from a VM on the LabSwitch** just to be safe

## Requirements
- LabSwitch from this guide
- DC01 with
    - DHCP (assumes 100-200 range, 200+ is static)
    - NAT'ing traffic to Internet
    - DNS

## Talos Control Plane
- VM 2x2
- LabSwitch network
- ISO for Talos

```
boot-cp.bat <ip> <name>
```

