function Convert-SIDToUser {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$SID
    )

    process {
        try {
            $securityIdentifier = [System.Security.Principal.SecurityIdentifier]::new($SID)
            $ntAccount = $securityIdentifier.Translate([System.Security.Principal.NTAccount])

            return $ntAccount.Value
        }
        catch {
            Write-Verbose "Failed to resolve SID '$SID': $_"
            return $null
        }
    }
}