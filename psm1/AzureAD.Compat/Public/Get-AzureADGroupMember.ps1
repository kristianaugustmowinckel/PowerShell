function Get-AzureADGroupMember {
    param(
        [Parameter(Mandatory)]
        [string]$ObjectId
    )

    Get-MgGroupMember -GroupId $ObjectId -All | ForEach-Object {
        switch ($_.AdditionalProperties.'@odata.type') {
            '#microsoft.graph.user' {
                Get-MgUser -UserId $_.Id
            }
            '#microsoft.graph.group' {
                Get-MgGroup -GroupId $_.Id
            }
            default {
                $_
            }
        }
    }
}