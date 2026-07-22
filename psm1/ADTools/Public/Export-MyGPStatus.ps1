function Export-MyGPStatus {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.IO.FileInfo])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Linked', 'UnLinked', 'All')]
        [string]$LinkStatus,

        [ValidateNotNullOrEmpty()]
        [string]$OutDir = '\\hvl.no\Tilsett\Data\IT\IT-Users\kam'
    )

    begin {
        if (-not (Test-Path -LiteralPath $OutDir -PathType Container)) {
            throw "Output directory '$OutDir' does not exist."
        }

        $xlsFile = Join-Path -Path $OutDir -ChildPath "gp-$LinkStatus.xlsx"
    }

    process {
        if ($PSCmdlet.ShouldProcess($xlsFile, 'Export Group Policy status')) {

            Write-Verbose "Exporting '$LinkStatus' Group Policy status to '$xlsFile'."

            Get-MyGPStatus -LinkStatus $LinkStatus |
                Export-Excel -Path $xlsFile `
                             -WorksheetName $LinkStatus `
                             -AutoSize `
                             -FreezeTopRow `
                             -FreezeTopRowFirstColumn `
                             -BoldTopRow `
                             -ErrorAction Stop

            Get-Item -LiteralPath $xlsFile
        }
    }
}