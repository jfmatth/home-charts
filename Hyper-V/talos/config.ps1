$Config = $null
$Config = [pscustomobject]@{
$TalosConfig = $null

$TalosConfig = [ordered]@{
    Cluster = @{
        Name        = "talos-hyperv"
        K8sEndpoint = "10.10.10.201"
    }

    Paths = @{
        ConfigDir   = ".\cluster-configs"
        PatchFolder = ".\controlplane-patches"
        PatchFile   = ".\controlplane-patches\cilium-kubeproxy.yaml"
        
        PatchFile   = "cp-patch.yaml"
    }

}
