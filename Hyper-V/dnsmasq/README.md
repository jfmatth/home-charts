# Build DNSMASQ Multipass VM for help with LabSwitch

## requirements
- Multipass installed (on Windows)
- Hyper-V switch called ``LabSwitch``

## Install

```
multipass launch `
  --name dnsmasq `
  --network name=LabSwitch `
  --cloud-init .\user-data.yaml `
  --memory 512M `
  --disk 5G `
  24.04
```