function Convert-ToExcelAllInDir {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [string]$Dir = 'C:\Users\kam\OneDrive - Høgskulen på Vestlandet\SHARE',

        [Parameter()]
        [string]$Delimiter = ';'
    )

    begin {
        if (-not (Get-Command Convert-ToExcel -ErrorAction SilentlyContinue)) {
            throw "Convert-ToExcel function was not found."
        }

        if (-not (Test-Path -LiteralPath $Dir)) {
            throw "Directory '$Dir' does not exist."
        }
    }

    process {
        Get-ChildItem -Path (Join-Path $Dir '*.csv') -File | ForEach-Object {

            $csv  = $_.FullName
            $xlsx = $_.FullName -replace '\.csv$', '.xlsx'

            if ($PSCmdlet.ShouldProcess($csv, "Convert to '$xlsx'")) {
                try {
                    Convert-ToExcel -Csv $csv -Xlsx $xlsx -Delimiter $Delimiter
                }
                catch {
                    Write-Warning "Failed to convert '$csv': $_"
                }
            }
        }
    }
}