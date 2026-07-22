function Start-MyEdge {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$InPrivate,
        [switch]$AzureAdmin
    )

    begin {
        $EdgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"

        if (-not (Test-Path $EdgePath)) {
            $EdgePath = "${env:ProgramFiles}\Microsoft\Edge\Application\msedge.exe"
        }

        if (-not (Test-Path $EdgePath)) {
            throw "Microsoft Edge could not be found."
        }

        $UserDataDir = Join-Path $env:TEMP 'kammsedge'

        $Url = if ($AzureAdmin) {
            'https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/ActivationMenuBlade/~/aadmigratedroles'
        }
        else {
            'https://www.google.com'
        }

        $ArgumentList = @()

        if ($InPrivate) {
            $ArgumentList += '--inprivate'
        }

        $ArgumentList += $Url
        $ArgumentList += "--user-data-dir=$UserDataDir"
    }

    process {
        if ($PSCmdlet.ShouldProcess($EdgePath, "Start Microsoft Edge")) {
            Start-Process -FilePath $EdgePath -ArgumentList $ArgumentList
        }
    }
}