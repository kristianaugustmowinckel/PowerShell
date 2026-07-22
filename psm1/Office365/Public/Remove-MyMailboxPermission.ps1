function Remove-MyMailboxPermission {
    [CmdletBinding(SupportsShouldProcess)]
	[OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$UserName
    )

    process {
        try {
            $Mailbox = Get-Mailbox -Identity $Name -ErrorAction Stop

            if ($PSCmdlet.ShouldProcess(
                $Mailbox.PrimarySmtpAddress,
                "Remove FullAccess and SendAs for $UserName"
            )) {

                Remove-MailboxPermission `
                    -Identity $Mailbox.PrimarySmtpAddress `
                    -User $UserName `
                    -AccessRights FullAccess `
                    -InheritanceType All `
                    -Confirm:$false `
                    -ErrorAction Stop

                Remove-RecipientPermission `
                    -Identity $Mailbox.PrimarySmtpAddress `
                    -Trustee $UserName `
                    -AccessRights SendAs `
                    -Confirm:$false `
                    -ErrorAction Stop
            }

            return $true
        }
        catch {
            Write-Error "Failed to remove permissions from mailbox '$Name' for user '$UserName'. $_"
            return $false
        }
    }
}