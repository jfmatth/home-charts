# Building an IIS lab on a laptop

The goal is to have a lab with the following:
- a local Domain / Forest called ``lab.local``
- DFS
- 2 x IIS Servers
- Sample websites for IIS

## Build Domain Controller for Forest / Domain
- Create VM from the Template
- Boot
- Rename to DC01
- Install Forest with script
    ```
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
    Install-ADDSForest `
        -DomainName "lab.local" `
        -DomainNetbiosName "LAB" `
        -SafeModeAdministratorPassword (ConvertTo-SecureString "W1nd0ws" -AsPlainText -Force) `
        -InstallDNS `
        -Force
    ```
    Many warnings about DHCP and non-static stuff, not to worry.
- VM will restart
- Login with your original administrator password
- You need to change the DNS forwarder address, the one that's found may not work due to the way Hyper-V sets IP's

## DFS Server and Files path
- Install DFS and create a fileshare
    ```
    # Variables
    $FolderPath = "C:\Files"
    $ShareName = "Files"
    $DomainName = (Get-ADDomain).DNSRoot
    $ServerName = $env:COMPUTERNAME

    # Install DFS Namespace role and management tools
    Install-WindowsFeature FS-DFS-Namespace -IncludeManagementTools

    # Create folder
    New-Item -Path $FolderPath -ItemType Directory -Force

    # Create SMB share
    New-SmbShare `
        -Name $ShareName `
        -Path $FolderPath `
        -FullAccess "Domain Admins" `
        -ChangeAccess "Domain Users"

    # Create DFS Namespace
    New-DfsnRoot `
        -TargetPath "\\$ServerName\$ShareName" `
        -Path "\\$DomainName\$ShareName" `
        -Type DomainV2

    # Add DFS Folder
    New-DfsnFolder `
        -Path "\\$DomainName\$ShareName\$ShareName" `
        -TargetPath "\\$ServerName\$ShareName"

    # Verify
    Get-DfsnRoot
    Get-DfsnFolder -Path "\\$DomainName\$ShareName\*"
    Get-SmbShare -Name $ShareName
    ```
