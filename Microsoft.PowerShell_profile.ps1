$mypsmodulespath = Join-Path (Split-Path $PROFILE) 'psm1'

# Import helper module
Import-Module (Join-Path $mypsmodulespath 'addpsmodulepath') -ErrorAction Stop

# Optional: keep PSModulePath updated for future sessions
Add-PSModulePath $mypsmodulespath | Out-Null

# Import custom modules
Get-ChildItem $mypsmodulespath -Directory |
Where-Object Name -ne 'addpsmodulepath' |
Sort-Object Name |
ForEach-Object {
    $module = $_

    try {
        switch ($module.Name.ToLower()) {

            'adtools' {
                if ($env:COMPUTERNAME -eq 'KRN-MGMT-01') {
                    Import-Module $module.FullName -Force -ErrorAction Stop
                }
                break
            }

            'office365' {
                if ($env:COMPUTERNAME -ne 'KRN-MGMT-01') {
                    Remove-Module ActiveDirectory -ErrorAction SilentlyContinue
                    Import-Module $module.FullName -Force -ErrorAction Stop
                }
                break
            }

            default {
                Import-Module $module.FullName -Force -ErrorAction Stop
            }
        }

        Write-Verbose "Loaded module: $($module.Name)"
    }
    catch {
        Write-Warning "Failed to load module '$($module.Name)': $_"
    }
}

# Save currently loaded functions
$sysfunctions = Get-ChildItem Function:

# User names
$myUsername = $env:USERNAME -replace '-admin$', ''
$myUsernameAdmin = "$myUsername-admin"
$myUsernameLokal = "$myUsername-lokal"

# Determine work folder
if (
    $myUsername -ne $env:USERNAME -and
    $env:COMPUTERNAME -in @('KRN-MGMT-01')
) {
    $work = (Split-Path $PROFILE) -replace '\\WindowsPowerShell$', '\w'
}
else {
    # Load Exchange Online module if available
    Import-Module ExchangeOnlineManagement -ErrorAction SilentlyContinue

    # Use OneDrive work folder
    $work = Join-Path $env:OneDrive 'Documents\w'
}

# Load PSReadLine if available
Import-Module PSReadLine -ErrorAction SilentlyContinue

# Ensure work folder exists
New-Item -ItemType Directory -Path $work -Force | Out-Null

# Start PowerShell in work folder
Set-Location $work
