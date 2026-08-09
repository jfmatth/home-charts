param(
    [Parameter(Mandatory = $true)]
    [string]$ControlPlaneDHCP
)

function Wait-ForKeypress {
    Read-Host "Press Enter to continue"
}

<#
.SYNOPSIS
    Talos v1.13 Setup Script
    DHCP runtime parameter + patch applied during gen config
    Patch file is NOT modified
#>

# -----------------------------
# Config Structure
# -----------------------------
$TalosConfig = [ordered]@{
    Cluster = @{
        Name        = "talos-hyperv"
        K8sEndpoint = "10.10.10.201"   # static endpoint
    }

    Nodes = @{
        ControlPlane = @($ControlPlaneDHCP)
        Workers      = @("192.168.50.11", "192.168.50.12")
    }

    Paths = @{
        ConfigDir   = ".\cluster-configs"
        PatchFile   = "controlplane-patch.yaml"   # used as-is
        Kubeconfig  = "kubeconfig"
    }

    Steps = @{
        ShowNodeIPs     = $true
        GenerateConfigs = $true

        ControlPlane = @{
            ApplyConfigs    = $true
            SetEndpoints    = $true
            BootstrapEtcd   = $true
            FetchKubeconfig = $true
        }

        Workers = @{
            ApplyConfigs = $true
        }

        VerifyCluster = $true
    }
}

# Build full HTTPS endpoint
$ApiEndpoint = "https://$($TalosConfig.Cluster.K8sEndpoint):6443"
$TalosConfigPath = Join-Path $TalosConfig.Paths.ConfigDir "talosconfig"

# -----------------------------
# Step 1: Display Node IPs
# -----------------------------
if ($TalosConfig.Steps.ShowNodeIPs) {
    Write-Host "Control Plane DHCP Boot IP:"
    Write-Host " - $ControlPlaneDHCP"

    Write-Host "Worker Nodes:"
    $TalosConfig.Nodes.Workers | ForEach-Object { Write-Host " - $_" }
}

# -----------------------------
# Step 2: Generate Configs (Patch applied as-is)
# -----------------------------
if ($TalosConfig.Steps.GenerateConfigs) {

    Write-Host "Generating Talos configs with controlplane patch..."

    $genStr = "talosctl gen config " +
              "$($TalosConfig.Cluster.Name) " +
              "$ApiEndpoint " +
              "--output $($TalosConfig.Paths.ConfigDir) " +
              "--config-patch-control-plane @$($TalosConfig.Paths.PatchFile) " +
              "--force"

    Write-Host "Executing:"
    Write-Host $genStr

    Wait-ForKeypress

    Invoke-Expression $genStr
}

# ⭐ Pause after generating configs
Wait-ForKeypress

# -----------------------------
# CONTROL PLANE CONFIG APPLY
# -----------------------------
if ($TalosConfig.Steps.ControlPlane.ApplyConfigs) {
    Write-Host "Applying controlplane config..."
    talosctl apply-config --insecure -n $ControlPlaneDHCP `
        --file "$($TalosConfig.Paths.ConfigDir)/controlplane.yaml"
}

# ⭐ Pause after applying controlplane config
Wait-ForKeypress

# -----------------------------
# CONTROL PLANE ENDPOINTS
# -----------------------------
if ($TalosConfig.Steps.ControlPlane.SetEndpoints) {
    Write-Host "Setting talosctl endpoints..."
    talosctl config endpoint $ApiEndpoint
    talosctl config node $ApiEndpoint
}

# -----------------------------
# CONTROL PLANE BOOTSTRAP
# -----------------------------
if ($TalosConfig.Steps.ControlPlane.BootstrapEtcd) {
    Write-Host "Bootstrapping etcd..."
    talosctl bootstrap -n $ApiEndpoint -e $ApiEndpoint --talosconfig $TalosConfigPath
}

# -----------------------------
# CONTROL PLANE KUBECONFIG
# -----------------------------
if ($TalosConfig.Steps.ControlPlane.FetchKubeconfig) {
    Write-Host "Fetching kubeconfig..."
    talosctl kubeconfig -n $ApiEndpoint $TalosConfig.Paths.Kubeconfig
}

# -----------------------------
# WORKER CONFIG APPLY
# -----------------------------
if ($TalosConfig.Steps.Workers.ApplyConfigs) {
    Write-Host "Applying worker configs..."
    foreach ($ip in $TalosConfig.Nodes.Workers) {
        talosctl apply-config --insecure -n $ip `
            --file "$($TalosConfig.Paths.ConfigDir)/worker.yaml"
    }
}

# -----------------------------
# VERIFY CLUSTER
# -----------------------------
if ($TalosConfig.Steps.VerifyCluster) {
    Write-Host "Checking Talos node health..."
    talosctl health

    Write-Host "Checking Kubernetes nodes..."
    kubectl --kubeconfig $TalosConfig.Paths.Kubeconfig get nodes -o wide
}

Write-Host "=== Talos Setup Complete ==="
