param(
    [Parameter(Mandatory = $true)]
    [string]$ControlPlaneDHCP
)
. .\config.ps1
. .\functions.ps1

function Get-ControlPlanePatchArgs {
    param(
        [string]$PatchFolder
    )

    if (-not (Test-Path $PatchFolder)) {
        return ""
    }

    $patches = Get-ChildItem -Path $PatchFolder -File |
        Sort-Object Name

    if (-not $patches) {
        return ""
    }

    return $patches | ForEach-Object {
        "--config-patch-control-plane=@$($_.FullName)"
    }
}

$debug = $true
if ($debug) {Set-StrictMode -Version 3.0} else {Set-StrictMode -off }

$talosConfig = Join-Path $Config.Paths.ConfigDir "talosconfig"
$kubeconfig  = Join-Path $Config.Paths.ConfigDir "kubeconfig"


Write-Host "Generating Talos files ..."
# $PatchFile = "@" + $Config.Paths.PatchFile
# $ApiEndpoint = "https://$($Config.Cluster.K8sEndpoint):6443"

$PatchArgs = Get-ControlPlanePatchArgs -PatchFolder $Config.Paths.PatchFolder
talosctl gen config `
    $($Config.Cluster.Name) "https://$($Config.Cluster.K8sEndpoint):6443" `
    --force `
    --output $Config.Paths.ConfigDir `
    $PatchArgs

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

