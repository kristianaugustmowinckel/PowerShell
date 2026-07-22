  function Get-DatamaskinStat {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [switch]$Detailed
    )

    begin {
        $BaseOU = 'OU=Datamaskiner,DC=hvl,DC=no'

        function Get-ComputerCount {
            param(
                [Parameter(Mandatory)]
                [string]$SearchBase
            )

            (Get-ADComputer -Filter * -SearchBase $SearchBase |
                Measure-Object).Count
        }
    }

    process {

        $ous = Get-ADOrganizationalUnit -Filter * -SearchBase $BaseOU -SearchScope OneLevel |
               Sort-Object Name

        foreach ($ou in $ous) {

            if ($ou.Name -in 'student', 'tilsett') {

                $subOUs = Get-ADOrganizationalUnit -Filter * `
                    -SearchBase $ou.DistinguishedName `
                    -SearchScope OneLevel |
                    Sort-Object Name

                foreach ($subOU in $subOUs) {

                    $count = Get-ComputerCount -SearchBase $subOU.DistinguishedName
                    "{0} {1} : {2}" -f $ou.Name, $subOU.Name, $count

                    if ($Detailed) {

                        $subSubOUs = Get-ADOrganizationalUnit -Filter * `
                            -SearchBase $subOU.DistinguishedName `
                            -SearchScope OneLevel |
                            Sort-Object Name

                        foreach ($subSubOU in $subSubOUs) {

                            $count = Get-ComputerCount -SearchBase $subSubOU.DistinguishedName
                            "{0} {1} {2} : {3}" -f $ou.Name, $subOU.Name, $subSubOU.Name, $count
                        }
                    }
                }
            }
            else {

                $count = Get-ComputerCount -SearchBase $ou.DistinguishedName
                "{0} : {1}" -f $ou.Name, $count
            }
        }
    }
}