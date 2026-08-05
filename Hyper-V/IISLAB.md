# Building an IIS lab on a laptop

The goal is to have a lab with the following:
- Internal network for all VM's (10.10.10.0/24)
- a local Domain / Forest called ``lab.local``
- DFS
- 2 x IIS Servers
- Sample websites for IIS

## Setup Switch, NAT and Network on Hyper-V host
**some items require Admin terminal**
- Create switch
    ```
    New-VMSwitch -Name LabSwitch -SwitchType Internal
    ```
- Static IP for Host (**Admin**)
    ```
    New-NetIPAddress `
    -InterfaceAlias "vEthernet (LabSwitch)" `
    -IPAddress 10.10.10.1 `
    -PrefixLength 24
    ```
- Create NAT (**Admin**)
    ```
    New-NetNat `
    -Name "LabNAT" `
    -InternalIPInterfaceAddressPrefix "10.10.10.0/24"
    ```

## Build Domain Controller for Forest / Domain
- Create VM from the Template
- Make sure you connect to the new LabSwitch network
- Boot
- Rename to DC01
- Assign IP and DNS
    ```
    New-NetIPAddress `
    -InterfaceAlias Ethernet `
    -IPAddress 10.10.10.10 `
    -PrefixLength 24 `
    -DefaultGateway 10.10.10.1

    Set-DnsClientServerAddress `
    -InterfaceAlias Ethernet `
    -ServerAddresses 10.10.10.10
    ```

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
- VM will restart
- Login with your original administrator password
- Install DHCP and setup
    ```
    Install-WindowsFeature DHCP `
    -IncludeManagementTools
    
    Add-DhcpServerv4Scope `
    -Name "Lab Scope" `
    -StartRange 10.10.10.100 `
    -EndRange 10.10.10.200 `
    -SubnetMask 255.255.255.0    
    
    Set-DhcpServerv4OptionValue `
    -DnsServer 10.10.10.10 `
    -Router 10.10.10.1 `
    -DnsDomain local.lab

    Add-DnsServerPrimaryZone `
    -NetworkId "10.10.10.0/24" `
    -ReplicationScope Forest
    ```

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
## IIS Server
- Create VM from the Template
- Boot
- Rename to IIS01
- Join Domain
    ```