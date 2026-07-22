function Get-EssentialUserInfo {
    [CmdletBinding()]
    param(
        [string]$InputString,
        [switch]$Ansatt,
        [switch]$Student
    )

    $user = Get-MyUserObject -InputString $InputString

    if (-not $user) {
        return
    }

    if ($Ansatt -and -not $Student) {
        $user = $user | Where-Object {
            'ansatt' -in ($_.extensionAttribute11 -split ',')
        }
    }
    elseif ($Student -and -not $Ansatt) {
        $user = $user | Where-Object {
            'student' -in ($_.extensionAttribute11 -split ',')
        }
    }

    $user | Select-Object `
        DisplayName,
        SamAccountName,
        Name,
        Company,
        Title,
        Department,
        @{
            Name = 'Manager'
            Expression = {
                if ($_.Manager) {
                    (Get-ADUser $_.Manager).Name
                }
            }
        },
        Office,
        Mail,
        UserPrincipalName,
        Enabled,
        LastLogonDate,
        TelephoneNumber,
        OtherMobile,
        Mobile,
        ExtensionAttribute1,
        ExtensionAttribute2,
        ExtensionAttribute3,
        ExtensionAttribute4,
        ExtensionAttribute5,
        ExtensionAttribute6,
        ExtensionAttribute7,
        ExtensionAttribute8,
        ExtensionAttribute9,
        ExtensionAttribute10,
        ExtensionAttribute11,
        ExtensionAttribute12,
        ExtensionAttribute13,
        ExtensionAttribute14
}