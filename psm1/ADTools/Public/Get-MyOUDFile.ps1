function Get-MyOUDFile {
    [CmdletBinding()]
    param()

    $users = Get-ADUser `
        -Filter * `
        -Properties ExtensionAttribute3, Department, Enabled `
        -ResultSetSize $null

    $enabled = $users |
        Where-Object { $_.ExtensionAttribute3 -and $_.Enabled } |
        Select-Object ExtensionAttribute3, Department |
        Sort-Object ExtensionAttribute3, Department -Unique

    $all = $users |
        Where-Object { $_.ExtensionAttribute3 } |
        Select-Object ExtensionAttribute3, Department |
        Sort-Object ExtensionAttribute3, Department -Unique

    $diff = Compare-Object $all $enabled `
        -Property ExtensionAttribute3, Department `
        -PassThru |
        Where-Object SideIndicator -eq '<='

    $result = $enabled |
        Select-Object ExtensionAttribute3, Department,
            @{Name='Enabled';Expression={ $true }}

    $result += $diff |
        Select-Object ExtensionAttribute3, Department,
            @{Name='Enabled';Expression={ $false }}

    $result |
        Sort-Object ExtensionAttribute3, Department |
        Export-Excel `
            -Path "\\hvl.no\Tilsett\Data\IT\IT-Users\kam\OUD.xlsx" `
            -AutoSize `
            -FreezeTopRow `
            -BoldTopRow
}