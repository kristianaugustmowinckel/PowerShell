function Search-PSHistory {
    <#
    .SYNOPSIS
        Searches the PSReadLine command history.

    .DESCRIPTION
        Reads the persistent PSReadLine history file and optionally filters
        the results using either wildcard matching or regular expressions.

    .PARAMETER Pattern
        Text or regex pattern to search for.

    .PARAMETER SimpleMatch
        Treat Pattern as literal text (wildcard search).

    .PARAMETER CaseSensitive
        Perform a case-sensitive search.

    .PARAMETER Last
        Return only the last N matching commands.

    .PARAMETER Tail
        Read only the last N lines from the history file before filtering.
        Useful for very large history files.

    .EXAMPLE
        Get-MyHistory

    .EXAMPLE
        Get-MyHistory git

    .EXAMPLE
        Get-MyHistory docker -SimpleMatch

    .EXAMPLE
        Get-MyHistory 'git\s+commit' -Last 20

    .EXAMPLE
        Get-MyHistory ssh -SimpleMatch -Tail 500
    #>

    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Pattern,

        [switch]$SimpleMatch,

        [switch]$CaseSensitive,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$Last,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$Tail
    )

    $historyFile = Join-Path $env:APPDATA 'Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt'

    if (-not (Test-Path -LiteralPath $historyFile)) {
        throw "PSReadLine history file not found:`n$historyFile"
    }

    # Read the history
    if ($PSBoundParameters.ContainsKey('Tail')) {
        $history = Get-Content -LiteralPath $historyFile -Tail $Tail
    }
    else {
        $history = Get-Content -LiteralPath $historyFile
    }

    # Filter if requested
    if ($PSBoundParameters.ContainsKey('Pattern')) {

        if ($SimpleMatch) {

            if ($CaseSensitive) {
                $history = $history | Where-Object { $_ -clike "*$Pattern*" }
            }
            else {
                $history = $history | Where-Object { $_ -like "*$Pattern*" }
            }

        }
        else {

            $history = $history |
                Select-String -Pattern $Pattern -CaseSensitive:$CaseSensitive |
                ForEach-Object Line

        }
    }

    # Return requested number of entries
    if ($PSBoundParameters.ContainsKey('Last')) {
        $history | Select-Object -Last $Last
    }
    else {
        $history
    }
}