param(
    [Parameter(Mandatory = $true)]
    [string]$ControlPlaneDHCP
)

$debug = $true
if ($debug) {Set-StrictMode -Version 3.0} else {Set-StrictMode -off }

. .\config.ps1

# $Config = $null
# $Config = [pscustomobject]@{
#     Cluster = @{
#         Name        = "talos-hyperv"
#         K8sEndpoint = "10.10.10.201"
#     }

#     Paths = @{
#         ConfigDir   = ".\cluster-configs"
#         PatchFile   = "cp-patch.yaml"
#     }

# }

$talosConfig = Join-Path $Config.Paths.ConfigDir "talosconfig"
$kubeconfig  = Join-Path $Config.Paths.ConfigDir "kubeconfig"

# # Load config
# . .\config.ps1
. .\functions.ps1

Write-Host "Generating Talos files ..."
# $PatchFile = "@" + $Config.Paths.PatchFile
# $ApiEndpoint = "https://$($Config.Cluster.K8sEndpoint):6443"
talosctl gen config $($Config.Cluster.Name) "https://$($Config.Cluster.K8sEndpoint):6443" `
--config-patch-control-plane `@$($Config.Paths.PatchFile) `
--force `
--output $Config.Paths.ConfigDir

if ($debug) {Wait-ForKeypress}

Write-Host "Applying controlplane config..."
talosctl apply-config `
    --insecure `
    -n $ControlPlaneDHCP `
    --file "$($Config.Paths.ConfigDir)/controlplane.yaml"
`
if ($debug) {Wait-ForKeypress} else {sleep 10}

Write-Host "Bootstrapping etcd..."
talosctl bootstrap `
    -n $($Config.Cluster.K8sEndpoint) `
    -e $($Config.Cluster.K8sEndpoint) `
    --talosconfig $talosConfig

# if ($debug) {Wait-ForKeypress}
Write-Host "Waiting on health..."
talosctl health `
    -n $($Config.Cluster.K8sEndpoint) `
    -e $($Config.Cluster.K8sEndpoint) `
    --talosconfig $talosConfig

.\setup-config.ps1

write-host "Done"

