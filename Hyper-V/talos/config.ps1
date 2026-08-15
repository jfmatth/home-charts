$TalosConfig = [ordered]@{
    Cluster = @{
        Name        = "talos-hyperv"
        K8sEndpoint = "10.10.10.201"   # static endpoint
    }

    Paths = @{
        ConfigDir   = ".\cluster-configs"
        PatchFile   = "cp-patch.yaml"   # used as-is
        Kubeconfig  = Join-Path $TalosConfig.Paths.ConfigDir "kubeconfig"
        talosconfig = Join-Path $TalosConfig.Paths.ConfigDir "talosconfig"
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
