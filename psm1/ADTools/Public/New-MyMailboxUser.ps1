function New-MyMailboxUser {

    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]

    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$MailboxName,

        [string]$OU = "hvl.no/Drift/Exchange/Funksjonskonto/hvl.no",

        [string]$Password,

        [string]$Description = "Shared Mailbox",

        [string]$ExchangeServer = "krn-ex19-01.hvl.no",

        [string]$DomainController = "krn-ad-01.hvl.no",

        [switch]$Single
    )

    begin {

        $Limit = 20

        $MailboxName = Convert-Norwegian $MailboxName.Trim()

        $EmailAddress = "$MailboxName@hvl.no"

        if ([string]::IsNullOrWhiteSpace($Password)) {
            $PlainPassword = New-RandomPassword 20
        }
        else {
            $PlainPassword = $Password
        }

        $SecurePassword = ConvertTo-SecureString $PlainPassword -AsPlainText -Force

        if ($Single) {
            Write-Verbose "Connecting to Exchange..."

            $Session = New-MyEMSSession -ExchangeServer $ExchangeServer

            Import-PSSession -Session $Session -DisableNameChecking -AllowClobber | Out-Null
        }
    }

    process {

        if ($MailboxName.Length -gt $Limit) {
            Write-Warning "$MailboxName exceeds the maximum length of $Limit characters."
            return
        }

        if (Test-ADObject -SAMName $MailboxName -Type User) {
            Write-Warning "User '$MailboxName' already exists."
            return
        }

        if ($PSCmdlet.ShouldProcess($MailboxName, "Create shared mailbox")) {

            try {

                Write-Verbose "Creating Remote Mailbox..."

                New-RemoteMailbox `
                    -Name $MailboxName `
                    -SamAccountName $MailboxName `
                    -DisplayName $MailboxName `
                    -Alias $MailboxName `
                    -UserPrincipalName $EmailAddress `
                    -PrimarySmtpAddress $EmailAddress `
                    -Password $SecurePassword `
                    -OnPremisesOrganizationalUnit $OU `
                    -Shared `
                    -ErrorAction Stop

                Set-ADUser `
                    -Identity $MailboxName `
                    -Description $Description `
                    -Server $DomainController `
                    -ErrorAction Stop

                Enable-ADAccount `
                    -Identity $MailboxName `
                    -Server $DomainController `
                    -ErrorAction Stop

                Write-Verbose "Successfully created mailbox '$MailboxName'."

                [PSCustomObject]@{
                    Name        = $MailboxName
                    Email       = $EmailAddress
                    Description = $Description
                    Created     = $true
                    Password    = if ([string]::IsNullOrWhiteSpace($Password)) { $PlainPassword } else { $null }
                }

            }
            catch {
                Write-Error "Failed to create mailbox '$MailboxName'. $_"
            }
        }
    }

    end {

        if ($Session) {
            Remove-PSSession $Session
        }

    }
}