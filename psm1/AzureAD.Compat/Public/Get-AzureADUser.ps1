function Get-AzureADUser {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param(
        [Parameter(ParameterSetName = 'ObjectId')]
        [string]$ObjectId,

        [Parameter(ParameterSetName = 'UserPrincipalName')]
        [string]$UserPrincipalName,

        [Parameter(ParameterSetName = 'Filter')]
        [string]$Filter,

        [string[]]$Property
    )

    $params = @{}

    if ($Property) {
        $params.Property = $Property
    }

    switch ($PSCmdlet.ParameterSetName) {
        'ObjectId' {
            Get-MgUser -UserId $ObjectId @params
        }

        'UserPrincipalName' {
            Get-MgUser -UserId $UserPrincipalName @params
        }

        'Filter' {
            Get-MgUser -Filter $Filter -All @params
        }

        default {
            Get-MgUser -All @params
        }
    }
}