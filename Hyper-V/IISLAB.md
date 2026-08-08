# Building an IIS lab on a laptop

The goal is to have a lab with the following:
- Internal network for all VM's (10.10.10.0/24)
- a local Domain / Forest called ``lab.local``
- DFS
- 2 x IIS Servers
- Sample websites for IIS

## Setup Switch, NAT and Network on Hyper-V host
**some items require Admin terminal**

This creates a new network on the host that allows the private 

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
- Create VM from the Template (see Templating.md)
- Make sure you connect to the new LabSwitch network
- Boot
- Rename to DC01, reboot
- Disable IPv6 / Assign IP and DNS
    ```
    Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6
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
- click Close, VM will restart
- Login with your original administrator password
- Install DHCP and setup
    ```
    Install-WindowsFeature DHCP -IncludeManagementTools
    
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

    Add-DhcpServerInDC -DnsName "dc01.local.lab" -IpAddress 10.10.10.10

    ```

    You might get an error on the last one but it works.

## File Server Share for sites
```
$Root = 'C:\sites'

$Folders = @(
    'site1',
    'site2',
    'site3',
    'shared'
)

New-Item -Path $Root -ItemType Directory -Force | Out-Null

foreach ($Folder in $Folders) {
    New-Item -Path (Join-Path $Root $Folder) -ItemType Directory -Force | Out-Null
}

icacls $Root /grant "Domain Users:(OI)(CI)M" /T

New-SmbShare `
    -Name "sites" `
    -Path $Root `
    -FullAccess "Domain Admins" `
    -ChangeAccess "Domain Users"
```


## IIS Server 01 and 02
- Create VM from the Template on LabSwitch network
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
- Add websites for every share we have

```
Import-Module WebAdministration

$Sites = @(
    @{
        Name = "site1"
        HostHeader = "site1.lab.local"
        Path = "\\dc01\sites\site1"
        Port = 80
    },
    @{
        Name = "site2"
        HostHeader = "site2.lab.local"
        Path = "\\dc01\sites\site2"
        Port = 80
    },
    @{
        Name = "site3"
        HostHeader = "site3.lab.local"
        Path = "\\dc01\sites\site3"
        Port = 80
    }
)

foreach ($Site in $Sites) {

    if (-not (Get-Website -Name $Site.Name -ErrorAction SilentlyContinue)) {

        New-Website `
            -Name $Site.Name `
            -PhysicalPath $Site.Path `
            -Port $Site.Port `
            -HostHeader $Site.HostHeader
    }
}


```
- Rinse and repeat for IIS02