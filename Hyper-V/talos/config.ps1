$Config = $null
$Config = [pscustomobject]@{
    Cluster = @{
        Name        = "talos-hyperv"
        K8sEndpoint = "10.10.10.201"
    }

    Paths = @{
        ConfigDir   = ".\cluster-configs"
        # PatchFile   = "cp-patch.yaml"
        # PatchFile   = "cp-patch-cilium-nokubeproxy.yaml"
        PatchFile   = "cp-patch-cilium-kubeproxy.yaml"
        
    }

}
