function Convert-Norwegian {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [AllowEmptyString()]
        [string]$Text
    )

    process {
        if ($null -eq $Text) {
            return $null
        }

        $Text.
            Replace('æ', 'a').
            Replace('ø', 'o').
            Replace('å', 'a').
            Replace('Æ', 'A').
            Replace('Ø', 'O').
            Replace('Å', 'A')
    }
}