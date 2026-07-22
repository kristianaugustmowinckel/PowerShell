function New-MyMailbox {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,

        [ValidateNotNullOrEmpty()]
        [string]$Alias,

        [ValidateNotNullOrEmpty()]
        [string]$PrimarySmtpAddress
    )

    begin {
        $DefaultDomain = "hvl.no"

        if (-not $DisplayName) {
            $DisplayName = $Name
        }

        if (-not $Alias) {
            $Alias = $Name
        }

        if (-not $PrimarySmtpAddress) {
            $PrimarySmtpAddress = "$Name@$DefaultDomain"
        }
    }

    process {

        Write-Verbose "Creating shared mailbox '$DisplayName' with address '$PrimarySmtpAddress'."

        if ($PSCmdlet.ShouldProcess(
                $PrimarySmtpAddress,
                "Create shared mailbox")) {

            try {

                $mailbox = New-Mailbox `
                    -Shared `
                    -Name $Name `
                    -DisplayName $DisplayName `
                    -Alias $Alias `
                    -PrimarySmtpAddress $PrimarySmtpAddress `
                    -ErrorAction Stop

                Write-Verbose "Shared mailbox '$DisplayName' created successfully."

                $mailbox
            }
            catch {
                Write-Error -Message "Failed to create shared mailbox '$Name'. $($_.Exception.Message)"
                Write-Verbose $_.ScriptStackTrace
            }
        }
    }
}