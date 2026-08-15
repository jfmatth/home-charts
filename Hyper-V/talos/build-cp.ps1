param(
    [Parameter(Mandatory = $true)]
    [string]$ControlPlaneDHCP
)

$debug = $true

# Load config
. .\config.ps1
. .\functions.ps1

# talos-bootcp.bat
# :main
#     @echo off
#     if "%1"=="" GOTO error
#     if "%2"=="" GOTO error

#     Echo Building Talos files
#     talosctl gen config %2 https://%1:6443 ^
#         --config-patch-control-plane @talos-cp-patch.yaml ^
#         --force

#     Echo Applying config to ControlPlane (step 1)
#     talosctl apply-config --insecure -n %1 --file ControlPlane.yaml

#     @ECHO.    
#     @ECHO When bootstrapping is ready...(if IP is diff, call talos-bootcont.bat, otherwise)
#     Pause

#     CALL talos-bootcont.bat %1 

$PatchFile = "@" + $TalosConfig.Paths.PatchFile
$ApiEndpoint = "https://$($TalosConfig.Cluster.K8sEndpoint):6443"

if ($debug) {Write-Host $PatchFile, $ApiEndpoint, $($TalosConfig.Paths.ConfigDir)}

Write-Host "Generating Talos files ..."
talosctl gen config $($Talosconfig.Cluster.Name) $ApiEndpoint `
--config-patch-control-plane $PatchFile `
--force `
--output $($TalosConfig.Paths.ConfigDir)

if ($debug) {Wait-ForKeypress}

Write-Host "Applying controlplane config..."
talosctl apply-config `
    --insecure `
    --nodes $ControlPlaneDHCP `
    --file "$($TalosConfig.Paths.ConfigDir)/controlplane.yaml"

if ($debug) {Wait-ForKeypress}

Write-Host "Bootstrapping etcd..."
$TalosConfigPath = $Talosconfig.Paths.talosconfig
talosctl bootstrap -n $($TalosConfig.Cluster.K8sEndpoint) -e $($TalosConfig.Cluster.K8sEndpoint) --talosconfig $TalosConfigPath

# if ($debug) {Wait-ForKeypress}
Write-Host "Waiting on health..."
talosctl health -n $($TalosConfig.Cluster.K8sEndpoint) -e $($TalosConfig.Cluster.K8sEndpoint) --talosconfig $TalosConfigPath

if ($debug) {Wait-ForKeypress}

Write-Host "Configuring talosconfig.."
talosctl --talosconfig $TalosConfigPath config endpoint $($TalosConfig.Cluster.K8sEndpoint)
talosctl --talosconfig $TalosConfigPath config node $($TalosConfig.Cluster.K8sEndpoint)
$env:TALOSCONFIG=$($talosconfig.Paths.talosconfig)

if ($debug) {Wait-ForKeypress}

Write-Host "Fetching kubeconfig.."
talosctl kubeconfig $($TalosConfig.Paths.kubeconfig)

if ($debug) {Wait-ForKeypress}


# # Build full HTTPS endpoint
# # $ApiEndpoint = "https://$($TalosConfig.Cluster.K8sEndpoint):6443"
# # $TalosConfigPath = Join-Path $TalosConfig.Paths.ConfigDir "talosconfig"

# # # -----------------------------
# # # Step 1: Display Node IPs
# # # -----------------------------
# # if ($TalosConfig.Steps.ShowNodeIPs) {
# #     Write-Host "Control Plane DHCP Boot IP:"
# #     Write-Host " - $ControlPlaneDHCP"

# #     Write-Host "Worker Nodes:"
# #     $TalosConfig.Nodes.Workers | ForEach-Object { Write-Host " - $_" }
# # }

# # # -----------------------------
# # # Step 2: Generate Configs (Patch applied as-is)
# # # -----------------------------
# # if ($TalosConfig.Steps.GenerateConfigs) {

# #     Write-Host "Generating Talos configs with controlplane patch..."

# #     $genStr = "talosctl gen config " +
# #               "$($TalosConfig.Cluster.Name) " +
# #               "$ApiEndpoint " +
# #               "--output $($TalosConfig.Paths.ConfigDir) " +
# #               "--config-patch-control-plane @$($TalosConfig.Paths.PatchFile) " +
# #               "--force"

# #     Write-Host "Executing:"
# #     Write-Host $genStr

# #     Wait-ForKeypress

# #     Invoke-Expression $genStr

# #     Wait-ForKeypress

# # }

# # # -----------------------------
# # # CONTROL PLANE CONFIG APPLY
# # # -----------------------------
# # if ($TalosConfig.Steps.ControlPlane.ApplyConfigs) {
# #     Write-Host "Applying controlplane config..."
# #     talosctl apply-config --insecure -n $ControlPlaneDHCP `
# #         --file "$($TalosConfig.Paths.ConfigDir)/controlplane.yaml"

# #     Wait-ForKeypress
# # }


# # -----------------------------
# # CONTROL PLANE ENDPOINTS
# # -----------------------------
# # if ($TalosConfig.Steps.ControlPlane.SetEndpoints) {
# #     Write-Host "Setting talosctl endpoints..."
# #     talosctl config endpoint $ApiEndpoint
# #     talosctl config node $ApiEndpoint
# #     talosctl config new "$($TalosConfig.$ApiEndpoint.Cluster.Name)"
# #     talosctl config context "$($TalosConfig.$ApiEndpoint.Cluster.Name)"

# #     Wait-ForKeypress
# # }

# # -----------------------------
# # CONTROL PLANE BOOTSTRAP
# # -----------------------------
# if ($TalosConfig.Steps.ControlPlane.BootstrapEtcd) {
#     Write-Host "Bootstrapping etcd..."
#     talosctl bootstrap -n $ApiEndpoint -e $ApiEndpoint --talosconfig $TalosConfigPath

#     Wait-ForKeypress
# }

# # -----------------------------
# # CONTROL PLANE KUBECONFIG
# # -----------------------------
# if ($TalosConfig.Steps.ControlPlane.FetchKubeconfig) {
#     Write-Host "Fetching kubeconfig..."
#     talosctl kubeconfig -n $ApiEndpoint $TalosConfig.Paths.Kubeconfig
# }

# # -----------------------------
# # WORKER CONFIG APPLY
# # -----------------------------
# if ($TalosConfig.Steps.Workers.ApplyConfigs) {
#     Write-Host "Applying worker configs..."
#     foreach ($ip in $TalosConfig.Nodes.Workers) {
#         talosctl apply-config --insecure -n $ip `
#             --file "$($TalosConfig.Paths.ConfigDir)/worker.yaml"
#     }
# }

# # -----------------------------
# # VERIFY CLUSTER
# # -----------------------------
# if ($TalosConfig.Steps.VerifyCluster) {
#     Write-Host "Checking Talos node health..."
#     talosctl health

#     Write-Host "Checking Kubernetes nodes..."
#     kubectl --kubeconfig $TalosConfig.Paths.Kubeconfig get nodes -o wide
# }

# Write-Host "=== Talos Setup Complete ==="
