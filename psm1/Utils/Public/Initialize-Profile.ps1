function Initialize-Profile {
    [CmdletBinding()]
    param()

    $modulePath = Join-Path (Split-Path $PROFILE) 'psm1'

    Add-PSModulePath $modulePath | Out-Null
    Import-ProfileModule -ModulePath $modulePath

    $envInfo = Initialize-UserEnvironment

    Import-Module PSReadLine -ErrorAction SilentlyContinue

    New-Item -ItemType Directory -Path $envInfo.WorkFolder -Force | Out-Null
    Set-Location $envInfo.WorkFolder
}