function Add-PSPath {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AddPath,

        [ValidateSet('Process','User','Machine')]
        [string]$Scope = 'Process'
    )

    if (-not (Test-Path $AddPath)) {
        Write-Error "Path does not exist: $AddPath"
        return $false
    }

    $AddPath = (Resolve-Path $AddPath).Path

    $paths = [Environment]::GetEnvironmentVariable('Path', $Scope).Split(';') |
             Where-Object { $_ } |
             ForEach-Object { $_.Trim() }

    if ($paths -contains $AddPath) {
        Write-Verbose "'$AddPath' already exists in PATH."
        return $true
    }

    $newPath = ($paths + $AddPath) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $newPath, $Scope)

    Write-Verbose "Added '$AddPath' to PATH ($Scope)."

    return $true
}