$TalosConfig = $null

$TalosConfig = [ordered]@{
    Cluster = @{
        Name        = "talos-hyperv"
        K8sEndpoint = "10.10.10.201"   # static endpoint
    }

    Paths = @{
        ConfigDir   = ".\cluster-configs"
        PatchFile   = "cp-patch.yaml"
    }

}
