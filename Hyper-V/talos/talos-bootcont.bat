:main

    talosctl bootstrap -n %1 -e %1  --talosconfig talosconfig
    
    @REM ECHO Setting endpoints and config file.
    set TALOS=10.10.10.201
    @REM COPY talosconfig %USERPROFILE%\.talos\config
    talosctl config endpoint %TALOS%
    talosctl config node %TALOS%
    talosctl kubeconfig -f

    talosctl dashboard -n %1 -e %1  --talosconfig talosconfig

    talosctl get members
    kubectl get nodes
    kubectl get pods -A