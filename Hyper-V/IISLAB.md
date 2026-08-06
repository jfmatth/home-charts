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
- Rename to DC01, reboot
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
- click OK, VM will restart
- Login with your original administrator password
- Install DHCP and setup
    ```
    Install-WindowsFeature DHCP -IncludeManagementTools
    
    Add-DhcpServerv4Scope `
    -Name "Lab Scope" `
    -StartRange 10.10.10.100 `
    -EndRange 10.10.10.200 `
    -SubnetMask 255.255.255.0    
    
    Add-DhcpServerInDC -DnsName "dc01.local.lab" -IpAddress 10.10.10.10

    Set-DhcpServerv4OptionValue `
    -DnsServer 10.10.10.10 `
    -Router 10.10.10.1 `
    -DnsDomain local.lab

    Add-DnsServerPrimaryZone `
    -NetworkId "10.10.10.0/24" `
    -ReplicationScope Forest
    ```

    - By-Hand - Authorize the scope on the 

<!-- - You need to change the DNS forwarder address, the one that's found may not work due to the way Hyper-V sets IP's -->

## DFS Server and Files path
- Install DFS and create a fileshare
    ```
    $FolderPath = "C:\DFSFolder"
    $ShareName = "IISSites"
    $DfsFolderName = "WebRoot"
    $DomainName = (Get-ADDomain).DNSRoot
    $ServerName = $env:COMPUTERNAME

    Install-WindowsFeature FS-DFS-Namespace -IncludeManagementTools
    New-Item -Path $FolderPath -ItemType Directory -Force
    New-SmbShare `
        -Name $ShareName `
        -Path $FolderPath `
        -FullAccess "Domain Admins" `
        -ChangeAccess "Domain Users"
    New-DfsnRoot `
        -TargetPath "\\$ServerName\$ShareName" `
        -Path "\\$DomainName\$ShareName" `
        -Type DomainV2
    New-DfsnFolder `
        -Path "\\$DomainName\$ShareName\$DfsFolderName" `
        -TargetPath "\\$ServerName\$ShareName"
    Get-DfsnRoot
    Get-DfsnFolder -Path "\\$DomainName\$ShareName\*"
    Get-SmbShare -Name $ShareName
    ```

## IIS Server 01 and 02
- Create VM from the Template
- Boot
- Rename to IIS01 or IIS02
- Join Domain
    ```
    $domain = "lab.local"
    $user = "lab\Administrator"
    $pass = Read-Host "Enter domain password" -AsSecureString
    $cred = New-Object System.Management.Automation.PSCredential($user,$pass)
    Add-Computer -DomainName $domain -Credential $cred -Force
    Restart-Computer

    ```  
- Install IIS
    ```
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools
    ```
- Add DFS path for drive **Broken right now** (rename DFS folder above)
    ```
    $dfsPath = "\\dc01.lab.local\IISSites"
    New-PSDrive -Name "F" -PSProvider FileSystem -Root $dfsPath -Persist

    New-PSDrive -Name F -PSProvider FileSystem -Root "\\dc01.lab.local\IISSites" -Persist

    ```
- Rinse and repeat for IIS02