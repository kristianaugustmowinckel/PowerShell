function Copy-FromRemoteComputer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,

        [Parameter(Mandatory)]
        [string]$Remote,

        [Parameter(Mandatory)]
        [string]$Local
    )

    $session = New-PSSession -ComputerName $ComputerName

    try {
        Copy-Item -FromSession $session `
                  -Path $Remote `
                  -Destination $Local `
                  -Recurse `
                  -ErrorAction Stop
        return $true
    }
    finally {
        if ($session) {
            Remove-PSSession $session
        }
    }
}