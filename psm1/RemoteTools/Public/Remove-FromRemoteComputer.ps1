function Remove-FromRemoteComputer {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$RemotePath
    )

    $scriptBlock = {
        param($Path)

        try {
            if (-not (Test-Path -LiteralPath $Path)) {
                return [PSCustomObject]@{
                    Success = $false
                    Exists  = $false
                    Path    = $Path
                    Message = "Path does not exist."
                }
            }

            Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop

            return [PSCustomObject]@{
                Success = $true
                Exists  = $true
                Path    = $Path
                Message = "Item removed successfully."
            }
        }
        catch {
            return [PSCustomObject]@{
                Success = $false
                Exists  = $true
                Path    = $Path
                Message = $_.Exception.Message
            }
        }
    }

    if ($PSCmdlet.ShouldProcess($ComputerName, "Remove '$RemotePath'")) {
        try {
            Invoke-MyCommand `
                -ComputerName $ComputerName `
                -ScriptBlock $scriptBlock `
                -ArgumentList $RemotePath `
                -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to execute remote command on '$ComputerName'. $($_.Exception.Message)"
        }
    }
}