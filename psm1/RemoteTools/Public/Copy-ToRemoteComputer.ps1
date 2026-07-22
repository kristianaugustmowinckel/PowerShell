function Copy-ToRemoteComputer {
    [CmdletBinding(SupportsShouldProcess = $true)]
	[OutputType([bool])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$ComputerName,

        [Parameter(Mandatory, Position = 1)]
        [ValidateScript({
            if (-not (Test-Path $_)) {
                throw "Local path '$_' does not exist."
            }
            $true
        })]
        [string]$Local,

        [Parameter(Mandatory, Position = 2)]
        [string]$Remote,

        [Parameter()]
        [System.Management.Automation.PSCredential]$Credential
    )

    $session = $null

    try {
        Write-Verbose "Creating PowerShell session to $ComputerName..."

        if ($Credential) {
            $session = New-PSSession -ComputerName $ComputerName -Credential $Credential -ErrorAction Stop
        }
        else {
            $session = New-PSSession -ComputerName $ComputerName -ErrorAction Stop
        }

        if ($PSCmdlet.ShouldProcess($ComputerName, "Copy '$Local' to '$Remote'")) {

            Write-Verbose "Copying '$Local' to '$Remote'..."

            Copy-Item `
                -Path $Local `
                -Destination $Remote `
                -ToSession $session `
                -Recurse `
                -Force `
                -ErrorAction Stop

            Write-Verbose "Copy completed successfully."
            return $true
        }
    }
    catch {
        Write-Error "Failed to copy '$Local' to '$ComputerName`: $($_.Exception.Message)"
        return $false
    }
    finally {
        if ($session) {
            Write-Verbose "Removing PowerShell session..."
            Remove-PSSession -Session $session
        }
    }
}