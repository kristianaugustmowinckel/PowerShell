function Connect-AzureAD {
    [CmdletBinding()]
    param(
        [string[]]$Scopes = @(
            "User.Read.All",
            "Group.ReadWrite.All"
        ),

        [string]$TenantId
    )

    if (-not (Get-Module -ListAvailable Microsoft.Graph.Authentication)) {
        throw "Microsoft.Graph PowerShell SDK is not installed."
    }

    $context = Get-MgContext

    if (-not $context) {
        if ($TenantId) {
            Connect-MgGraph -TenantId $TenantId -Scopes $Scopes
        }
        else {
            Connect-MgGraph -Scopes $Scopes
        }
    }

    Get-MgContext
}