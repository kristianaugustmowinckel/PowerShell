function Get-MyMailboxPermission {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$UserName
    )

    if ($UserName) {
        Get-MailboxPermission -Identity $Name -User $UserName
        Get-RecipientPermission -Identity $Name -Trustee $UserName

        Get-Mailbox -Identity $Name |
            Select-Object DisplayName,
                @{Name='SendOnBehalf';Expression={$_.GrantSendOnBehalfTo}}
    }
    else {
        Get-MailboxPermission -Identity $Name
        Get-RecipientPermission -Identity $Name

        Get-Mailbox -Identity $Name |
            Select-Object DisplayName,
                @{Name='SendOnBehalf';Expression={$_.GrantSendOnBehalfTo}}
    }
}