$patches = Get-ChildItem `
    -Path .\controlplane-patches `
    -Filter *.yaml |
    Sort-Object Name |
    Select-Object -ExpandProperty FullName

$PatchArgs = foreach ($PatchFile in $patches)
{
    '--config-patch-control-plane'
    "@$PatchFile" 
}

write-host $PatchArgs