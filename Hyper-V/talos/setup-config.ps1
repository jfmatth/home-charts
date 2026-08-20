. .\config.ps1

Write-Host "Configuring talosconfig.."
talosctl --talosconfig $talosConfig config endpoint $($Config.Cluster.K8sEndpoint)
talosctl --talosconfig $talosConfig config node $($Config.Cluster.K8sEndpoint)
$env:TALOSCONFIG=$($talosConfig)

Write-Host "Fetching kubeconfig.."
talosctl kubeconfig $($kubeconfig)  --force
$env:KUBECONFIG=$($kubeconfig)

Write-host "Proof.."
talosctl get members
kubectl get nodes
kubectl get pods -A
