function Invoke-CreateOUDFile {

    [CmdletBinding()]
    param()

    begin {

        $MyDir = "\\hvl.no\tilsett\Data\IT\IT-Users\kam"

        $ModulePath = Join-Path (Split-Path $profile) "psm1\adtools"

        $OUDFile = Join-Path $ModulePath "OUDexported.csv"
        $OrgFile = Join-Path $ModulePath "orgstruktur.csv"

        $OUDNames = @()
        $OrgNames = @()

        if (Test-Path $OUDFile) {
            $OUDNames = Import-Csv $OUDFile
        }

        if (Test-Path $OrgFile) {
            $OrgNames = Import-Csv $OrgFile
        }

        #
        # Build lookup tables
        #
        $OUDLookup = @{}
        foreach ($row in $OUDNames) {
            $OUDLookup[$row.OUD] = $row.OUDNAME
        }

        $OrgLookup = @{}
        foreach ($row in $OrgNames) {
            $OrgLookup[$row.Orgeh] = $row.Orgehover
        }

        #
        # Retrieve only the properties we actually use
        #
        $Users = Get-ADUser `
            -Filter * `
            -Properties CanonicalName, Department, ExtensionAttribute3 |
            Where-Object {
                $_.CanonicalName -like 'hvl.no/Brukere/Ansatte/HRDB/*'
            }
    }

    process {

        #
        # OUD export
        #
        $OUDHash = $Users |
            Where-Object ExtensionAttribute3 |
            Select-Object `
                @{Name='OUD';Expression={$_.ExtensionAttribute3}},
                @{Name='OUDNAME';Expression={$OUDLookup[$_.ExtensionAttribute3]}} |
            Sort-Object OUD -Unique

        #
        # Organization export
        #
        $OUDOrgHash = $Users |
            Where-Object ExtensionAttribute3 |
            Select-Object `
                @{Name='Orgeh';Expression={$_.ExtensionAttribute3}},
                @{Name='Navn';Expression={$_.Department}},
                @{Name='Kortnavn';Expression={$OUDLookup[$_.ExtensionAttribute3]}},
                @{Name='Orgehover';Expression={$OrgLookup[$_.ExtensionAttribute3]}} |
            Sort-Object Orgeh -Unique

        #
        # Export generated files
        #
        $OUDHash |
            Export-Csv (Join-Path $MyDir "OUDexported-a.csv") `
                -NoTypeInformation `
                -Encoding UTF8

        $OUDOrgHash |
            Export-Csv (Join-Path $MyDir "orgstruktur-a.csv") `
                -NoTypeInformation `
                -Encoding UTF8

        #
        # Export source files (normalized)
        #
        $OUDNames |
            Export-Csv (Join-Path $MyDir "OUDexported.csv") `
                -NoTypeInformation `
                -Encoding UTF8

        $OrgNames |
            Export-Csv (Join-Path $MyDir "orgstruktur.csv") `
                -NoTypeInformation `
                -Encoding UTF8
    }

    end {
        Write-Verbose "Export complete."
    }
}