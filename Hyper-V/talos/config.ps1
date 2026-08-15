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
        talosconfig = $TalosConfig.Paths.ConfigDir + "\" + "talosconfig"
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
