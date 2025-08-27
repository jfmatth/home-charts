
# Kubernetes stuff (Thanks Andy R)
Set-Alias k kubectl
function dn {
    param (
        [string]$namespace
    )
    kubectl config set-context --current --namespace=$namespace
}
function kgp {
    kubectl get pods
}

function kgd {
    kubectl get deploy
}

function kgh {
    kubectl get httproute
}

function kgs {
    kubectl get svc
}

function kgg {
    kubectl get gateway
}

Set-Alias ll dir
Set-Alias t talosctl
Set-Alias docker podman
$env:PATH += ";C:\Program Files\PostgreSQL\17\bin"

# WOW
Set-PSReadLineOption -PredictionViewStyle listview
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineOption -PredictionViewStyle listview
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward


$versionMinimum = [Version]'7.1.999'

if (($host.Name -eq "ConsoleHost") -and ($PSVersionTable.PSVersion -ge $versionMinimum))
{
    Import-Module PSReadLine
}

Set-PSReadLineOption -Colors @{
    "Command" = [ConsoleColor]::Blue
    "Comment" = [ConsoleColor]::Yellow
    "Error" = [ConsoleColor]::DarkRed
    "Selection" = [ConsoleColor]::Yellow
    "String" = [ConsoleColor]::DarkGreen
    "Number" = [ConsoleColor]::DarkGreen
    "ListPredictionSelected" = [ConsoleColor]::Red
}

# Works across Windows, macOS, Linux

# Basic Aliases (override default if needed)
Set-Alias ls Get-ChildItem -Force
Set-Alias ll Get-ChildItem
Set-Alias la Get-ChildItem -Force
Set-Alias cat Get-Content -Force
Set-Alias mv Move-Item -Force
Set-Alias rm Remove-Item -Force
Set-Alias pwd Get-Location -Force
Set-Alias man Get-Help -Force
Set-Alias grep Select-String
Set-Alias touch New-Item -Force
Set-Alias which Get-Command


function reload-profile { . $PROFILE }

Write-Host "✅ PowerShell profile loaded!" -ForegroundColor Green
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
Write-Host "OS: $([System.Runtime.InteropServices.RuntimeInformation]::OSDescription)" -ForegroundColor Cyan
Write-Host "User: $env:USERNAME" -ForegroundColor Cyan
Write-Host "Host: $env:COMPUTERNAME" -ForegroundColor Cyan
