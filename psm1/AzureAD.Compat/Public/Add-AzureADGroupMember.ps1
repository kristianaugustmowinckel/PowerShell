function Add-AzureADGroupMember {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$GroupName,

        [Parameter(Mandatory)]
        [string]$UserPrincipalName
    )

    try {
        # Get the group
        $group = Get-MgGroup -Filter "displayName eq '$GroupName'" -ErrorAction Stop

        if (-not $group) {
            throw "Group '$GroupName' was not found."
        }

        if ($group.Count -gt 1) {
            throw "Multiple groups found with the name '$GroupName'. Please use the Group Id instead."
        }

        # Get the user
        $user = Get-MgUser -UserId $UserPrincipalName -ErrorAction Stop

        if (-not $user) {
            throw "User '$UserPrincipalName' was not found."
        }

        # Check if the user is already a member
        $member = Get-MgGroupMember -GroupId $group.Id -All |
            Where-Object Id -eq $user.Id

        if ($member) {
            Write-Verbose "'$UserPrincipalName' is already a member of '$GroupName'."
            return
        }

        if ($PSCmdlet.ShouldProcess($UserPrincipalName, "Add to group '$GroupName'")) {
            New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id -ErrorAction Stop
            Write-Verbose "Added '$UserPrincipalName' to '$GroupName'."
        }
    }
    catch {
        Write-Error $_
    }
}