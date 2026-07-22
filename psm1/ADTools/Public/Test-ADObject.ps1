function Test-ADObject {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string]$SAMName,

        [Parameter(Mandatory)]
        [ValidateSet(
            "user",
            "group",
            "computer",
            "organizationalUnit",
            "container",
            "contact"
        )]
        [string]$Type,

        [string]$LDAP = "LDAP://krn-ad-02.hvl.no/dc=hvl,dc=no"
    )

    $objDomain = $null
    $objSearcher = $null

    try {
        # Escape LDAP special characters
        $EscapedName = [System.DirectoryServices.Protocols.LdapFilter]::Escape($SAMName)

        $objDomain = New-Object System.DirectoryServices.DirectoryEntry($LDAP)
        $objSearcher = New-Object System.DirectoryServices.DirectorySearcher($objDomain)

        $objSearcher.PageSize = 1000
        $objSearcher.SearchScope = [System.DirectoryServices.SearchScope]::Subtree

        switch ($Type) {
            "user" {
                $objSearcher.Filter = "(&(objectCategory=user)(sAMAccountName=$EscapedName))"
            }
            "group" {
                $objSearcher.Filter = "(&(objectCategory=group)(sAMAccountName=$EscapedName))"
            }
            default {
                $objSearcher.Filter = "(&(objectCategory=$Type)(name=$EscapedName))"
            }
        }

        return ($null -ne $objSearcher.FindOne())
    }
    catch {
        Write-Verbose "Error searching Active Directory: $($_.Exception.Message)"
        return $false
    }
    finally {
        if ($objSearcher) { $objSearcher.Dispose() }
        if ($objDomain)   { $objDomain.Dispose() }
    }
}