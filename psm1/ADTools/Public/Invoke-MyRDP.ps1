function Invoke-MyRDP {

    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ImportFile = "ServiceNow-ComputerList-ROOM-B312.txt",

        [switch]$Connect,

        [switch]$Offline,

        [switch]$ShowTestResults,

        [switch]$ShowElapsedTime
    )

    begin {

        $RDPFolder = Join-Path $env:USERPROFILE 'Documents\RDP'

        $ImportFile = Join-Path $RDPFolder $ImportFile

        $ConnectionFile = Join-Path $RDPFolder 'RDPtoIntuneDevices.rdp'

        if (-not (Test-Path $ImportFile)) {
            throw "Import file not found: $ImportFile"
        }

        if (-not (Test-Path $ConnectionFile)) {
            throw "Connection file not found: $ConnectionFile"
        }

        try {
            $File = Import-Csv -Path $ImportFile -Delimiter ';' -ErrorAction Stop
        }
        catch {
            throw "Unable to read CSV file.`n$($_.Exception.Message)"
        }

        if ($File.Count -eq 0) {
            throw "CSV file contains no entries."
        }

        foreach ($Column in 'ip','host') {
            if ($File[0].PSObject.Properties.Name -notcontains $Column) {
                throw "CSV is missing required column '$Column'."
            }
        }

    }

    process {

        foreach ($Computer in $File) {

            $IP = $Computer.ip
            $HostName = $Computer.host

            $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

            $TestResult = Test-NetConnection `
                -ComputerName $IP `
                -Port 3389 `
                -WarningAction SilentlyContinue `
                -InformationAction SilentlyContinue `
                -ErrorAction SilentlyContinue

            $Stopwatch.Stop()

            $Elapsed = $Stopwatch.Elapsed

            if ($ShowElapsedTime) {
                Write-Output ("{0,-20} {1,-15} {2}" -f $HostName,$IP,$Elapsed)
            }

            $Online = $TestResult.TcpTestSucceeded

            if ($Online) {

                $Result = [PSCustomObject]@{
                    Hostname = $HostName
                    IP       = $IP
                    Online   = $true
                    Time     = $Elapsed
                }

                $Result

                if ($ShowTestResults) {
                    $TestResult
                }

                if ($Connect) {

                    Start-Process mstsc.exe -ArgumentList @(
                        $ConnectionFile
                        "/v:$IP"
                    )

                    Invoke-MyPause
                }

            }
            elseif ($Offline) {

                $Result = [PSCustomObject]@{
                    Hostname = $HostName
                    IP       = $IP
                    Online   = $false
                    Time     = $Elapsed
                }

                $Result

                if ($ShowTestResults) {
                    $TestResult
                }

            }

        }

    }

}