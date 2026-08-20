# Build VM templates in Hyper-V
Use Hyper-V on laptops or servers to build VM labs

- Template for Windows 2025 server
- "cloning" to make copies and use as lab VMs

## Requirements
- Windows 2025 ISO

## Building a template VM VHDX hard disk
- Create a new VM for Windows 2025
    - CPU / Memory / Default Switch
    - New Hard disk
    - Attach Windows Server ISO to VM
    - **Disable Checkpoints**

- Install Windows 2025 and sysprep
    - Desktop (not Core, yet)
    - Install Powershell 7 ONLY via install .EXE, winget will break it  
        [Releases](https://github.com/PowerShell/PowerShell/releases)
    - Fully Patch the box
    - Reboot
    - Sysprep  
        ``C:\Windows\System32\Sysprep\sysprep.exe /oobe /generalize /shutdown``
    - Close the Window for the VM, VM should shutdown after ~10m

## New VM from differenced VHDX
- Clone disk and create new machine
    - New -> Hard Disk
        - Source disk from above
        - Differencing
    - New Virtual Machine
        - Use the HD from above as the disk, do you do new
    - Boot new VM, should come up in sysprep'd mode, i.e. new server


## Issues with NIC names
If you change the switch the VM is connected to for the new VM, it may create a new NIC name i.e. ethernet 2 vs ethernet

- Fix the NIC name so other scripts work
```
Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Rename-NetAdapter -NewName "Ethernet"
```