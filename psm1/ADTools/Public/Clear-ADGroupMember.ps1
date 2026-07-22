function Clear-ADGroupMember {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName,

        [string]$LDAP = 'LDAP://krn-ad-02.hvl.no/dc=hvl,dc=no'
    )

    begin {
        $Server = ($LDAP -replace '^LDAP://', '') -replace '/.*', ''
    }

    process {
        if (-not (Test-ADObject -SAMName $GroupName -Type Group)) {
            Write-Warning "Group '$GroupName' does not exist."
            return $false
        }

        try {
            $members = Get-ADGroupMember -Identity $GroupName -Server $Server -ErrorAction Stop
        }
        catch {
            Write-Error $_
            return $false
        }

        if (-not $members) {
            Write-Verbose "Group '$GroupName' is already empty."
            return $true
        }

        Write-Verbose "Found $($members.Count) member(s) in '$GroupName':"

        foreach ($member in $members) {
            Write-Verbose "  $($member.Name)"
        }

        if ($PSCmdlet.ShouldProcess($GroupName, "Remove all $($members.Count) members")) {
            try {
                Remove-ADGroupMember `
                    -Identity $GroupName `
                    -Members $members `
                    -Server $Server `
                    -Confirm:$false `
                    -ErrorAction Stop

                Write-Verbose "Successfully removed $($members.Count) member(s) from '$GroupName'."

                return $true
            }
            catch {
                Write-Error "Failed to clear group '$GroupName'. $_"
                return $false
            }
        }
    }
}