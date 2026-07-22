function Get-MyGPStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Linked','UnLinked','All')]
        [string]$LinkStatus
    )

    $gpall = Get-GPO -All | Sort-Object DisplayName

    $gplinked = Get-ADOrganizationalUnit -Filter * |
        Get-GPInheritance |
        ForEach-Object { $_.GpoLinks } |
        Where-Object { $_.DisplayName } |
        Sort-Object DisplayName -Unique

    switch ($LinkStatus) {
        'Linked' {
            $out = $gpall | Where-Object {
                $_.DisplayName -in $gplinked.DisplayName
            }
        }

        'UnLinked' {
            $out = $gpall | Where-Object {
                $_.DisplayName -notin $gplinked.DisplayName
            }
        }

        'All' {
            $out = $gpall
        }
    }

    $out |
        Sort-Object DisplayName |
        Select-Object DisplayName,
                      Owner,
                      GpoStatus,
                      User,
                      Computer,
                      CreationTime,
                      ModificationTime,
                      Id,
                      DomainName,
                      WmiFilter,
                      Description,
                      Path
}