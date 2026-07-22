function Get-AzureADGroup {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param(
        [Parameter(
            ParameterSetName = 'ObjectId',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ObjectId,

        [Parameter(ParameterSetName = 'DisplayName')]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,

        [Parameter(ParameterSetName = 'Filter')]
        [ValidateNotNullOrEmpty()]
        [string]$Filter
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ObjectId' {
                return Get-MgGroup -GroupId $ObjectId
            }

            'DisplayName' {
                $escaped = $DisplayName.Replace("'", "''")
                return Get-MgGroup -Filter "displayName eq '$escaped'" -All
            }

            'Filter' {
                return Get-MgGroup -Filter $Filter -All
            }

            default {
                return Get-MgGroup -All
            }
        }
    }
}