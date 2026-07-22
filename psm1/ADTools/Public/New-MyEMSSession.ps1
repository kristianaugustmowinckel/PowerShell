function New-MyEMSSession {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$ExchangeServer = "krn-ex19-01.hvl.no"
    )

    if ($PSCmdlet.ShouldProcess($ExchangeServer, "Create Exchange PowerShell session")) {
        try {
            New-PSSession `
                -ConfigurationName Microsoft.Exchange `
                -ConnectionUri "http://$ExchangeServer/PowerShell/" `
                -Authentication Kerberos `
                -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to connect to Exchange server '$ExchangeServer': $_"
        }
    }
}