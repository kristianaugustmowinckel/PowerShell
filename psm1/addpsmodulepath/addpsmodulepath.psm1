# Load private functions
Get-ChildItem "$PSScriptRoot\Private\*.ps1" | ForEach-Object {
    . $_.FullName
}

# Load public functions
Get-ChildItem "$PSScriptRoot\Public\*.ps1" | ForEach-Object {
    . $_.FullName
}

# Export all public functions
Export-ModuleMember -Function (
    Get-ChildItem "$PSScriptRoot\Public\*.ps1" |
        Select-Object -ExpandProperty BaseName
)