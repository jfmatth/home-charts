:main
    @echo off
    if "%1"=="" GOTO error
    if "%2"=="" GOTO error

    Echo Building Talos files
    talosctl gen config %2 https://%1:6443 ^
        --config-patch-control-plane @talos-cp-patch.yaml ^
        --force

    Echo Applying config to ControlPlane (step 1)
    talosctl apply-config --insecure -n %1 --file ControlPlane.yaml

    @ECHO.
    @ECHO When bootstrapping is ready...(if IP is diff, call talos-bootcont.bat, otherwise)
    Pause

    CALL talos-bootcont.bat %1

    GOTO end

:error
    Echo Improper parameters given
    ECHO talos-bootcp.bat [CP IP] [NAME]
    GOTO end

:error-apply
    ECHO Error applying config
    GOTO end

:end