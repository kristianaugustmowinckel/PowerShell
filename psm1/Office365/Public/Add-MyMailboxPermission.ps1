function Add-MyMailboxPermission {
    [CmdletBinding(SupportsShouldProcess)]
	[OutputType([bool])]
    Param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$UserName
    )

    Begin {
        if (-not $UserName) {
            $UserName = "g-ex-" + ($Name -replace "@.*","")
        }
    }

    Process {
        try {
            $mailbox = Get-Mailbox -Identity $Name -ErrorAction Stop

            if ($PSCmdlet.ShouldProcess("$Name -> $UserName", "Grant FullAccess + SendAs")) {

                # FullAccess (skip if exists)
                $existing = Get-MailboxPermission -Identity $mailbox.PrimarySmtpAddress |
                            Where-Object { $_.User -like $UserName -and $_.AccessRights -contains "FullAccess" }

                if (-not $existing) {
                    Add-MailboxPermission `
                        -Identity $mailbox.PrimarySmtpAddress `
                        -User $UserName `
                        -AccessRights FullAccess `
                        -InheritanceType All `
                        -Confirm:$false
                }

                # SendAs (skip if exists)
                $existingSendAs = Get-RecipientPermission -Identity $mailbox.PrimarySmtpAddress |
                                  Where-Object { $_.Trustee -like $UserName -and $_.AccessRights -contains "SendAs" }

                if (-not $existingSendAs) {
                    Add-RecipientPermission `
                        -Identity $mailbox.PrimarySmtpAddress `
                        -Trustee $UserName `
                        -AccessRights SendAs `
                        -Confirm:$false
                }
            }

            return $true
        }
        catch {
            Write-Error "Failed to set permissions on mailbox '$Name' for '$UserName'. Error: $_"
            return $false
        }
    }
}