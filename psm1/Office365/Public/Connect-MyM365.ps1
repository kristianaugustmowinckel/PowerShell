function Connect-MyM365 {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$ExchangeOnline,
        [switch]$MgGraph
    )

    process {

        if (-not ($ExchangeOnline -or $MgGraph)) {
            Write-Warning "Specify at least one service: -ExchangeOnline or -MgGraph."
            return
        }

        if ($MgGraph) {
            if ($PSCmdlet.ShouldProcess("Microsoft Graph", "Connect")) {
                Connect-MgGraph -Scopes @(
                    "User.Read.All"
                    "Group.ReadWrite.All"
                    "Directory.ReadWrite.All"
                )
            }
        }

        if ($ExchangeOnline) {
            if ($PSCmdlet.ShouldProcess("Exchange Online", "Connect")) {
                Connect-ExchangeOnline
            }
        }
    }
}