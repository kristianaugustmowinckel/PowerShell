function Get-WorkFolder {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$User
    )

    if (
        $User.User -ne $env:USERNAME -and
        $env:COMPUTERNAME -in @(
            'KRN-MGMT-01',
            'KRN-ONEMIG-02'
        )
    ) {
        return (Split-Path $PROFILE) -replace '\\WindowsPowerShell$', '\w'
    }

    Import-Module ExchangeOnlineManagement -ErrorAction SilentlyContinue

    return (Join-Path $env:OneDrive 'Documents\w')
}