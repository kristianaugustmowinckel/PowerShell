function Convert-DataUTF8 {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$File
    )

    try {
        if ($PSCmdlet.ShouldProcess($File, 'Convert file to UTF-8')) {
            $content = Get-Content -Path $File -Raw

            Set-Content -Path $File -Value $content -Encoding UTF8 -ErrorAction Stop
        }

        return $true
    }
    catch {
        Write-Error $_
        return $false
    }
}