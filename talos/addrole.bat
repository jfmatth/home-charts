:main
    @echo off
    if "%1"=="" GOTO error
    if "%2"=="" GOTO error

    talosctl apply-config --insecure --nodes %1 --file %2
    PAUSE
    talosctl dashboard -n %1 -e %1

    GOTO end
:error
    Echo no talos ip declared
    GOTO end

:end 