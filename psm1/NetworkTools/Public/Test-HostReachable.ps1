function Test-HostReachable {

    [CmdletBinding()]
    [OutputType([bool])]

    param(
        [Parameter()]
        [string]$ComputerName = 'localhost',

        [Parameter()]
        [ValidateRange(1,60000)]
        [int]$Timeout = 100
    )

    $Ping = [System.Net.NetworkInformation.Ping]::new()

    try {
        $Reply = $Ping.Send($ComputerName, $Timeout)
        return ($Reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success)
    }
    catch {
        Write-Verbose $_.Exception.Message
        return $false
    }
    finally {
        $Ping.Dispose()
    }
}