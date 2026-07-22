function New-MyMailboxGroup {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$MailboxName,

        [string]$Description,

        [string]$ExchangeServer = "krn-ex19-01.hvl.no",

        [string]$DomainController = "krn-ad-02.hvl.no",

        [switch]$Single
    )

    begin {

        $MailboxName = Convert-Norwegian $MailboxName

        $Name  = "g-ex-$MailboxName"

        $Path = "OU=hvl.no,OU=Funksjonskonto,OU=Exchange,OU=Drift,DC=hvl,DC=no"

        if ([string]::IsNullOrWhiteSpace($Description)) {
            $Description = "Tilgangsgruppe for $MailboxName"
        }

        if ($Single) {
            Write-Verbose "Connecting to Exchange..."

            $Session = New-MyEMSSession -ExchangeServer $ExchangeServer
            Import-PSSession -Session $Session -AllowClobber | Out-Null
        }
    }

    process {

        if (Test-ADObject -SAMName $Name -Type Group) {
            Write-Verbose "Group '$Name' already exists."
            return
        }

        if ($PSCmdlet.ShouldProcess($Name, "Create mailbox security group")) {

            try {

                Write-Verbose "Creating AD group..."

                New-ADGroup `
                    -Server $DomainController `
                    -Name $Name `
                    -SamAccountName $Name `
                    -GroupCategory Security `
                    -GroupScope Universal `
                    -DisplayName $Name `
                    -Path $Path `
                    -Description $Description `
                    -ErrorAction Stop

                Set-ADGroup `
                    -Server $DomainController `
                    -Identity $Name `
                    -Replace @{
                        extensionAttribute2 = "ExchangeStyringsgruppe"
                    } `
                    -ErrorAction Stop

                Enable-DistributionGroup `
                    -DomainController $DomainController `
                    -Identity $Name `
                    -ErrorAction Stop

                Set-ADGroup `
                    -Server $DomainController `
                    -Identity $Name `
                    -Replace @{
                        msExchHideFromAddressLists = $true
                    } `
                    -ErrorAction Stop

                Write-Verbose "Mailbox group '$Name' created successfully."

                Get-ADGroup -Server $DomainController -Identity $Name
            }
            catch {
                Write-Error "Failed to create mailbox group '$Name'. $_"
            }
        }
    }

    end {

        if ($Single -and $Session) {
            Remove-PSSession $Session
        }
    }
}