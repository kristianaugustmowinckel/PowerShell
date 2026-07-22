function Get-MyUserObject {
    [CmdletBinding()]
    param(
        [string]$InputString
    )

    if ([string]::IsNullOrWhiteSpace($InputString)) {
        return
    }

    if (Test-ADObject -SAMName $InputString -Type user) {
        Get-ADUser -Identity $InputString -Properties *
    }
    else {
        Get-ADUser -Filter {
            DisplayName -like $InputString -or
            Mail -like $InputString -or
            UserPrincipalName -like $InputString
        } -Properties *
    }
}