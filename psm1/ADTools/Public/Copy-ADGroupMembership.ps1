function Copy-ADGroupMembership {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FromGroup,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ToGroup,

        [string]$LDAP = "LDAP://krn-ad-02.hvl.no/dc=hvl,dc=no"
    )

    begin {
        $Server = ($LDAP -replace '^LDAP://', '') -replace '/.*', ''
    }

    process {

        if (-not (Test-ADObject -SAMName $FromGroup -Type Group -LDAP $LDAP)) {
            Write-Verbose "The group '$FromGroup' does not exist."
            return $false
        }

        if (-not (Test-ADObject -SAMName $ToGroup -Type Group -LDAP $LDAP)) {
            Write-Verbose "The group '$ToGroup' does not exist."
            return $false
        }

        try {

            # Existing members of destination group
            $existingMembers = [System.Collections.Generic.HashSet[string]]::new(
                [StringComparer]::OrdinalIgnoreCase
            )

            Get-ADGroupMember -Identity $ToGroup -Server $Server |
                ForEach-Object {
                    $null = $existingMembers.Add($_.SamAccountName)
                }

            # Copy members
            Get-ADGroupMember -Identity $FromGroup -Server $Server |
                Where-Object objectClass -eq 'user' |
                ForEach-Object {

                    if ($existingMembers.Contains($_.SamAccountName)) {
                        return
                    }

                    if ($PSCmdlet.ShouldProcess($ToGroup, "Add member '$($_.SamAccountName)'")) {

                        Write-Verbose "Adding '$($_.SamAccountName)' to '$ToGroup'."

                        Add-ADGroupMember `
                            -Identity $ToGroup `
                            -Members $_ `
                            -Server $Server `
                            -ErrorAction Stop

                        $null = $existingMembers.Add($_.SamAccountName)
                    }
                }

            return $true
        }
        catch {
            Write-Error $_
            return $false
        }
    }
}