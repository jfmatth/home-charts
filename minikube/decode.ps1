function Decode-K8sSecret {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$Namespace = "default"
    )

    $secret = kubectl get secret $Name -n $Namespace -o json | ConvertFrom-Json

    if (-not $secret.data) {
        Write-Warning "Secret '$Name' has no data fields."
        return
    }

    $data = $secret | Select-Object -ExpandProperty data

    $data.PSObject.Properties | ForEach-Object {
        $key = $_.Name
        $raw = $_.Value

        $decoded = [System.Text.Encoding]::UTF8.GetString(
            [Convert]::FromBase64String($raw)
        )

        [PSCustomObject]@{
            Key   = $key
            Value = $decoded
        }
    }
}
