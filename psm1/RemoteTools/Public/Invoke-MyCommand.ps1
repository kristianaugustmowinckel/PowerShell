function Invoke-MyCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,

        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,

        [System.Management.Automation.Runspaces.PSSession]$Session,

        [object[]]$ArgumentList
    )

    $CreatedSession = $false

    try {
        if (-not $Session) {
            Write-Verbose "Creating session to $ComputerName"
            $Session = New-MyPSSession -ComputerName $ComputerName
            $CreatedSession = $true
        }

        if (-not $Session) {
            throw "Failed to create a PowerShell session to '$ComputerName'."
        }

        Write-Verbose "Executing remote command"

        Invoke-Command `
            -Session $Session `
            -ScriptBlock $ScriptBlock `
            -ArgumentList $ArgumentList `
            -ErrorAction Stop
    }
    catch {
        Write-Error $_
    }
    finally {
        if ($CreatedSession -and $Session) {
            Write-Verbose "Removing temporary session"
            Remove-PSSession -Session $Session
        }
    }
}