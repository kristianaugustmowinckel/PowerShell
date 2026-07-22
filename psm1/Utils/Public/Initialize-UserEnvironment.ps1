function Initialize-UserEnvironment {
    [CmdletBinding()]
    param()

    $user = Get-UserNames
    $work = Get-WorkFolder -User $user

    [PSCustomObject]@{
        User       = $user.User
        Admin      = $user.Admin
        Lokal      = $user.Lokal
        WorkFolder = $work
    }
}