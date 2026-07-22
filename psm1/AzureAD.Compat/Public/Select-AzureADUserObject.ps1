function Select-AzureADUserObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $User
    )

    process {
        [PSCustomObject]@{
            ObjectId           = $User.Id
            UserPrincipalName  = $User.UserPrincipalName
            DisplayName        = $User.DisplayName
            Mail               = $User.Mail
            AccountEnabled     = $User.AccountEnabled
        }
    }
}