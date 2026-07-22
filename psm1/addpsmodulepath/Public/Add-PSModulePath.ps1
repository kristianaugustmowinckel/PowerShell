function Add-PSModulePath {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [ValidateSet('Process','User','Machine')]
        [string]$Scope = 'User'
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        Write-Verbose "Path '$Path' does not exist."
        return $false
    }

    $Path = (Resolve-Path -LiteralPath $Path).ProviderPath

    $separator = [IO.Path]::PathSeparator

    $current = [Environment]::GetEnvironmentVariable(
        "PSModulePath",
        [EnvironmentVariableTarget]::$Scope
    )

    $paths = @()

    if ($current) {
        $paths = $current -split [regex]::Escape($separator)
    }

    if ($paths -contains $Path) {
        Write-Verbose "'$Path' is already in PSModulePath."
        return $true
    }

    $paths += $Path
    $newValue = $paths -join $separator

    if ($PSCmdlet.ShouldProcess($Scope, "Add '$Path' to PSModulePath")) {
        [Environment]::SetEnvironmentVariable(
            "PSModulePath",
            $newValue,
            [EnvironmentVariableTarget]::$Scope
        )
    }

    Write-Verbose "Added '$Path' to PSModulePath."
    return $true
}