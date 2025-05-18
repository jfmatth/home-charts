:main

    talosctl bootstrap -n %1 -e %1  --talosconfig talosconfig
    talosctl dashboard -n %1 -e %1  --talosconfig talosconfig

    ECHO Setting endpoints and config file.
    set TALOS=192.168.100.140
    COPY talosconfig %USERPROFILE%\.talos\config
    talosctl config endpoint %TALOS%
    talosctl config node %TALOS%
    talosctl kubeconfig -f

    talosctl get members
    kubectl get nodes
    kubectl get pods -A