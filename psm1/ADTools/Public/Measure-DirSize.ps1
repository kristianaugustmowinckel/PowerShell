function Measure-DirSize {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        [string]$Path
    )

    process {
        $size = (Get-ChildItem -Path $Path -File -Recurse -Force -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum

        [PSCustomObject]@{
            Path = (Resolve-Path $Path).Path
            SizeMB = [math]::Round($size / 1MB, 2)
            SizeGB = [math]::Round($size / 1GB, 2)
        }
    }
}