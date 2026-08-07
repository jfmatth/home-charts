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
    - Disable Checkpoints

- Install Windows 2025 and sysprep
    - Desktop (not Core, yet)
    - Fully Patch the box
    - Reboot
    - Possible fixing of APPx packages
        - Get-AppxPackage Microsoft.DesktopAppInstaller
        - Get-AppxProvisionedPackage -Online  
        Might have to work with AI to figure this all out
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
