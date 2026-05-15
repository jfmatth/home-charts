function Get-KubeSecret {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string]$SecretName,
        [Parameter(Mandatory = $false)] [string]$Namespace = "default"
    )

    $json = kubectl get secret $SecretName -n $Namespace -o json 2>$null | ConvertFrom-Json
    if (-not $json) { return $null }

    $secretData = @{}
    foreach ($prop in $json.data.psobject.Properties) {
        $secretData[$prop.Name] = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($prop.Value))
    }

    return $secretData
}