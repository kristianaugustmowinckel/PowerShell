function Export-MyFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$Object,

        [Parameter(Mandatory)]
        [string]$File,

        [string[]]$Property
    )

    begin {
        $directory = '.\RS'

        if (-not (Test-Path $directory)) {
            $null = New-Item -ItemType Directory -Path $directory
        }

        $path = Join-Path $directory "$File.xlsx"

        $items = @()
    }

    process {
        $items += $Object
    }

    end {

        if ($Property) {
            $exportObject = $items | Select-Object -Property $Property
        }
        else {
            $exportObject = $items
        }

        if ($PSCmdlet.ShouldProcess($path, 'Export Excel')) {

            if (Test-Path $path) {
                Remove-Item $path -Force
            }

            $exportObject |
                Export-Excel `
                    -Path $path `
                    -AutoSize `
                    -FreezeTopRow `
                    -FreezeFirstColumn `
                    -BoldTopRow
        }

    }
}