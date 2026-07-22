function Get-ADComputerList {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.IO.FileInfo[]])]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$OutDir = '\\hvl.no\tilsett\Data\IT\IT-Users\kam',

        [string]$UserSearchBase = 'OU=HRDB,OU=Ansatte,OU=Brukere,DC=hvl,DC=no'
    )

    begin {
        if (-not (Test-Path -LiteralPath $OutDir)) {
            $null = New-Item -Path $OutDir -ItemType Directory -Force
        }

        $UserFile     = Join-Path $OutDir 'ADUsers.xlsx'
        $ComputerFile = Join-Path $OutDir 'ADComputers.xlsx'
    }

    process {

        if ($PSCmdlet.ShouldProcess($UserFile, 'Export Active Directory users')) {

            try {

                Get-ADUser `
                    -Filter * `
                    -SearchBase $UserSearchBase `
                    -Properties LastLogonDate,
                                Company,
                                Title,
                                Department,
                                Manager,
                                Office,
                                Mail,
                                UserPrincipalName,
                                TelephoneNumber,
                                OtherMobile,
                                Mobile,
                                ExtensionAttribute1,
                                ExtensionAttribute2,
                                ExtensionAttribute3,
                                ExtensionAttribute4,
                                ExtensionAttribute5,
                                ExtensionAttribute6 |
                    Sort-Object Name |
                    Select-Object Name,
                                  SamAccountName,
                                  Enabled,
                                  LastLogonDate,
                                  Company,
                                  Title,
                                  Department,
                                  Manager,
                                  Office,
                                  Mail,
                                  UserPrincipalName,
                                  TelephoneNumber,
                                  OtherMobile,
                                  Mobile,
                                  ExtensionAttribute1,
                                  ExtensionAttribute2,
                                  ExtensionAttribute3,
                                  ExtensionAttribute4,
                                  ExtensionAttribute5,
                                  ExtensionAttribute6 |
                    Export-Excel -Path $UserFile `
                                 -AutoSize `
                                 -BoldTopRow `
                                 -FreezeTopRow `
                                 -FreezeFirstColumn

            }
            catch {
                Write-Error "Failed to export AD users. $_"
            }
        }

        if ($PSCmdlet.ShouldProcess($ComputerFile, 'Export Active Directory computers')) {

            try {

                Get-ADComputer `
                    -Filter * `
                    -Properties OperatingSystem,
                                OperatingSystemVersion,
                                CanonicalName,
                                Description,
                                Enabled |
                    Sort-Object Name |
                    Select-Object Name,
                                  OperatingSystem,
                                  OperatingSystemVersion,
                                  CanonicalName,
                                  Description,
                                  Enabled |
                    Export-Excel -Path $ComputerFile `
                                 -AutoSize `
                                 -BoldTopRow `
                                 -FreezeTopRow `
                                 -FreezeFirstColumn

            }
            catch {
                Write-Error "Failed to export AD computers. $_"
            }
        }
    }

    end {
        Get-Item -LiteralPath $UserFile, $ComputerFile -ErrorAction SilentlyContinue
    }
}