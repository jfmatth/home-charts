:main
    @echo off
    if "%1"=="" GOTO error


    Echo Building Talos files (v1.10.1)
    talosctl gen config talos-k8s https://192.168.100.140:6443 ^
        --config-patch-control-plane @cp-1-patch.yaml ^
        --config-patch-worker @nd-1-patch.yaml ^
        --install-image factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.10.1 ^
        --force

    Echo Applying config to ControlPlane (step 1)
    talosctl apply-config --insecure -n %1 --file ControlPlane.yaml

    IF NOT ERRORLEVEL 0 GOTO error-apply

    @ECHO.
    @ECHO When bootstrapping is ready...(if IP is diff, call boot-cont.bat, otherwise)
    Pause

    CALL boot-cont.bat %1

    @REM talosctl bootstrap -n %1 -e %1  --talosconfig talosconfig
    @REM talosctl dashboard -n %1 -e %1  --talosconfig talosconfig

    @REM ECHO Setting endpoints and config file.
    @REM set TALOS=192.168.100.130
    @REM COPY talosconfig %USERPROFILE%\.talos\config
    @REM talosctl config endpoint %TALOS%
    @REM talosctl config node %TALOS%
    @REM talosctl kubeconfig -f

    @REM talosctl get members
    @REM kubectl get nodes
    @REM kubectl get pods -A


    GOTO end

:error
    Echo no talos ip declared
    GOTO end

:error-apply
    ECHO Error applying config
    GOTO end

:end