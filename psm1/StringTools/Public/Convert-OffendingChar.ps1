function Convert-OffendingChar {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Text
    )

    process {
        if ([string]::IsNullOrWhiteSpace($Text)) {
            return $null
        }

        # Replace invalid filename characters with a hyphen
        $Text = $Text -replace '[\\/:*?"<>|]', '-'

        # Replace commas (with or without following spaces) with a hyphen
        $Text = $Text -replace ',\s*', '-'

        # Remove periods
        $Text = $Text -replace '\.', ''

        # Collapse multiple hyphens into one
        $Text = $Text -replace '-{2,}', '-'

        # Trim leading/trailing hyphens and spaces
        $Text = $Text.Trim(' ','-')

        return $Text
    }
}