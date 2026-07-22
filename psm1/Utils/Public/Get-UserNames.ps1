function Get-UserNames {
    [CmdletBinding()]
    param()

    $username = $env:USERNAME -replace '-admin$', ''

    [PSCustomObject]@{
        User  = $username
        Admin = "$username-admin"
        Lokal = "$username-lokal"
    }
}