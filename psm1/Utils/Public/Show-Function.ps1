function Show-Function {
    [CmdletBinding()]
    param()

    $excludedModules = @(
        '',
        'tmpEXO_*',
        'PowerShellGet',
        'MicrosoftTeams',
        'ExchangeOnlineManagement',
        'ISE',
        'Microsoft.PowerShell.Utility',
        'ImportExcel'
    )

    Get-ChildItem Function: |
        Where-Object {
            $module = $_.ModuleName

            $module -and -not (
                $excludedModules |
                Where-Object { $module -like $_ }
            )
        } |
        Sort-Object ModuleName, Name
}