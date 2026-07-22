function New-MyPSSession {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('CN','Name')]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName
    )

    begin {
        $SessionOption = New-PSSessionOption `
            -IdleTimeout 60000 `
            -OpenTimeout 10000 `
            -OperationTimeout 30000

        try {
            $UserName = ($env:USERNAME -replace '-.*', '') + '-lokal'

            $Credential = Get-MyCred `
                -UserName $UserName `
                -Domain 'hvl.no'
        }
        catch {
            throw "Failed to retrieve credentials. $_"
        }
    }

    process {
        foreach ($Computer in $ComputerName) {

            Write-Verbose "Testing connectivity to $Computer..."

            if (-not (Test-HostReachable -ComputerName $Computer)) {
                Write-Warning "$Computer is unreachable."
                continue
            }

            if ($PSCmdlet.ShouldProcess($Computer, "Create PowerShell session")) {

                try {
                    Write-Verbose "Connecting to $Computer..."

                    $Session = New-PSSession `
                        -ComputerName $Computer `
                        -Credential $Credential `
                        -SessionOption $SessionOption `
                        -ErrorAction Stop

                    Write-Verbose "Connected to $Computer."

                    $Session
                }
                catch {
                    Write-Error "Failed to create PSSession to '$Computer'. $($_.Exception.Message)"
                }
            }
        }
    }
}