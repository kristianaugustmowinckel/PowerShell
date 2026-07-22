function Convert-ToString {
    [CmdletBinding()]
    param(
        [object[]]$Obj,
        [string]$Sep = ","
    )

    ($Obj | ForEach-Object {
        if ($_ -ne $null) {
            $_.ToString().Trim()
        }
    }) -join $Sep
}