@ECHO OFF
if "%1"=="" GOTO error

Echo 4-node cluster (2xcp + 2xnd)
talosctl gen config talos-home https://%1:6443  --force

Echo Applying config to ControlPlane (step 1)
PAUSE
talosctl apply-config --insecure -n %1 --file ControlPlane.yaml

IF NOT ERRORLEVEL 0 GOTO error-apply

@ECHO.
@ECHO When bootstrapping is ready...
Pause

@ECHO ON
talosctl bootstrap -n %1 -e %1  --talosconfig talosconfig
talosctl dashboard -n %1 -e %1  --talosconfig talosconfig

ECHO Setting endpoints and config file.
@echo on
set TALOS=%1
COPY talosconfig %USERPROFILE%\.talos\config
talosctl config endpoint %1
talosctl config node %1

talosctl kubeconfig -f

talosctl get members
kubectl get nodes
kubectl get pods -A


GOTO end

:error
    Echo no talos ip declared
    GOTO end

:error-apply
    ECHO Error applying config
    GOTO end

:end