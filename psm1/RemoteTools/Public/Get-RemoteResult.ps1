function Get-RemoteResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,

        [Parameter(Mandatory)]
        [string]$Command,

        [System.Management.Automation.Runspaces.PSSession]$Session
    )

    $createdSession = $false

    if (-not $Session) {
        $Session = New-MyPSSession -ComputerName $ComputerName
        $createdSession = $true
    }

    try {
        Invoke-Command -Session $Session -ScriptBlock {
            param(
                [string]$Command
            )

            cmd.exe /c $Command
        } -ArgumentList $Command

    }
    finally {
        if ($createdSession -and $Session) {
            Remove-PSSession $Session
        }
    }
}