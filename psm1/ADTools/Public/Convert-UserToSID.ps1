 function Convert-UserToSID {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Identity', 'UserName', 'SamAccountName')]
        [ValidateNotNullOrEmpty()]
        [string]$User
    )

    process {
        try {
            return ([System.Security.Principal.NTAccount]$User).
                Translate([System.Security.Principal.SecurityIdentifier]).
                Value
        }
        catch {
            Write-Verbose "Failed to resolve user '$User' to a SID. $_"
            return $null
        }
    }
}