function Test-ADGroupMembership {
    param(
        [string]$Group,
        [string]$Object,
        [string]$LDAP = "LDAP://krn-ad-02.hvl.no/dc=hvl,dc=no"
    )

    $Server = ($LDAP -replace '^LDAP://','') -replace '/.*',''

    if (-not (Test-ADObject -SAMName $Group -Type group -LDAP $LDAP)) {
        return $false
    }

    if (-not (
        (Test-ADObject -SAMName $Object -Type user -LDAP $LDAP) -or
        (Test-ADObject -SAMName $Object -Type computer -LDAP $LDAP)
    )) {
        return $false
    }

    return (Get-ADGroupMember -Identity $Group -Server $Server |
            Select-Object -ExpandProperty SamAccountName) -contains $Object
}