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