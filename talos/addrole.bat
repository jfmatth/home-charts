:main
    @echo off
    if "%1"=="" GOTO error
    if "%2"=="" GOTO error

    talosctl apply-config --insecure --nodes %1 --file %2

    GOTO end
:error
    Echo no talos ip AND/OR role declared
    GOTO end

:end 