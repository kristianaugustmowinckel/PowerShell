function Convert-ToExcel {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Csv,

        [Parameter(Mandatory)]
        [string]$Xlsx,

        [string]$Delimiter = ';'
    )

    $excel = $null
    $workbook = $null
    $worksheet = $null
    $query = $null

    try {
        if (-not $PSCmdlet.ShouldProcess($Xlsx, 'Convert CSV to Excel')) {
            return
        }

        $excel = New-Object -ComObject Excel.Application
        $excel.DisplayAlerts = $false
        $excel.Visible = $false

        $workbook = $excel.Workbooks.Add()
        $worksheet = $workbook.Worksheets.Item(1)

        $query = $worksheet.QueryTables.Add(
            "TEXT;$Csv",
            $worksheet.Range("A1")
        )

        $query.TextFileParseType = 1            # xlDelimited
        $query.TextFileOtherDelimiter = $Delimiter
        $query.TextFileColumnDataTypes = ,1 * 256
        $query.AdjustColumnWidth = $true

        $query.Refresh()
        $query.Delete()

        $xlOpenXMLWorkbook = 51
        $workbook.SaveAs($Xlsx, $xlOpenXMLWorkbook)

        Get-Item $Xlsx
    }
    finally {
        if ($workbook) {
            $workbook.Close($false)
        }

        if ($excel) {
            $excel.Quit()
        }

        foreach ($obj in @($query, $worksheet, $workbook, $excel)) {
            if ($null -ne $obj) {
                [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($obj)
            }
        }

        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }
}