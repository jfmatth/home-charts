# Running linux desktop on Hyper-V

## Fedora 44

```
sudo dnf update -y

sudo dnf install hyperv-tools
sudo dnf install xrdp xorgxrdp
```

/etc/xrdp/xrdp.ini
```
vmconnect=true
```

```
sudo chcon -t bin_t /usr/sbin/xrdp
sudo chcon -t bin_t /usr/sbin/xrdp-sesman
```

Hyper-V VM changes
```
Set-VM -VMName "Your_Fedora_VM_Name" -EnhancedSessionTransportType HvSocket
```