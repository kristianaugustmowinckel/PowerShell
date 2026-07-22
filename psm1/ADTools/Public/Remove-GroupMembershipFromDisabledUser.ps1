function Remove-GroupMembershipFromDisabledUser {

    [CmdletBinding(
        SupportsShouldProcess = $true,
        DefaultParameterSetName = 'List'
    )]

    param(
        [Parameter(ParameterSetName = 'List')]
        [switch]$List,

        [Parameter(ParameterSetName = 'Remove')]
        [switch]$Remove,

        [string]$Server = 'krn-ad-02.hvl.no'
    )

    begin {

        $ExcludedGroups = @(
            'SEC-HVL-Ansatte'
            'SEC-HVL-Studenter'
            'MGMT-OU-Datamaskiner-ComputerAdmin'
            'AGPM-Approver_GPO_-1-761706572'
            'Cloud-IT-Test-godkjenning-11849592737'
            'Symmetry-ACSUsers'
            't-filimport'
            'MGMT-KRN-CPI-Sysmon'
            'SEC-HVL-KEEPER-SERVER'
            'SEC-HVL-SLNX-Admins'
            'MGMT-CPI-Helpdesk-Admins'
            'SEC-HVL-SOG-VPN-FoU'
            'SEC-HVL-SOG-VPN-Brukere'
            'HVL-SEC-VLAB-Brukarar'
            'HVL-SEC-VLAB-Brukarar-phtest'
            'HVL-SEC-SILAF-TEST-Medlemmer'
            'HVL-SEC-VLAB-Brukarar-SimaPro'
        )

        $ExcludedPatterns = @(
            'HVL-FOU-*'
            'HVL-SEC-NSD-*'
            'HVL-SEC-LG-FOU-*'
            'HVL-SEC-FOU-*'
        )

        $Users = Get-ADUser `
            -Server $Server `
            -SearchBase 'OU=Inaktive,OU=brukere,DC=hvl,DC=no' `
            -SearchScope Subtree `
            -LDAPFilter '(!(userAccountControl:1.2.840.113556.1.4.803:=2))' `
            -Properties MemberOf,SamAccountName

        # If your "Inaktive" OU contains disabled users only,
        # replace the LDAP filter above with:
        #
        # -Filter 'Enabled -eq $false'
        #
        # depending on your AD environment.
    }

    process {

        foreach ($User in $Users | Sort-Object SamAccountName) {

            Write-Verbose "Checking $($User.SamAccountName)"

            $Groups = foreach ($DN in $User.MemberOf) {

                Get-ADGroup `
                    -Identity $DN `
                    -Server $Server `
                    -Properties DisplayName,SamAccountName
            }

            $Groups = $Groups | Where-Object {

                $_.SamAccountName -notin $ExcludedGroups

            } | Where-Object {

                $Name = $_.SamAccountName

                foreach ($Pattern in $ExcludedPatterns) {
                    if ($Name -like $Pattern) {
                        return $false
                    }
                }

                return $true
            }

            if ($List) {

                [PSCustomObject]@{
                    User         = $User.SamAccountName
                    DisplayName  = $User.Name
                    Groups       = ($Groups.SamAccountName -join ',')
                    GroupCount   = $Groups.Count
                }

            }

            if ($Remove) {

                foreach ($Group in $Groups) {

                    if ($PSCmdlet.ShouldProcess(
                        $User.SamAccountName,
                        "Remove from group '$($Group.SamAccountName)'"
                    )) {

                        try {

                            Remove-ADGroupMember `
                                -Identity $Group `
                                -Members $User `
                                -Confirm:$false `
                                -Server $Server `
                                -ErrorAction Stop

                            Write-Verbose "Removed $($User.SamAccountName) from $($Group.SamAccountName)"

                        }
                        catch {

                            Write-Warning "Failed to remove $($User.SamAccountName) from $($Group.SamAccountName): $_"

                        }
                    }
                }
            }
        }
    }
}