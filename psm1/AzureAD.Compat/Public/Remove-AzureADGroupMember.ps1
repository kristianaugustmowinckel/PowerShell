function Remove-AzureADGroupMember {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [string]$GroupName,

        [Parameter(Mandatory)]
        [string]$UserPrincipalName
    )

    # Find matching groups
    $groups = Get-MgGroup -Filter "displayName eq '$GroupName'"

    if (-not $groups) {
        throw "Group '$GroupName' was not found."
    }

    if ($groups.Count -gt 1) {
        $groupList = $groups | ForEach-Object {
            "DisplayName: $($_.DisplayName), Id: $($_.Id), Mail: $($_.Mail)"
        }

        throw @"
Multiple groups with the name '$GroupName' were found.

Matching groups:
$($groupList -join [Environment]::NewLine)

Please specify the group by its Object ID instead.
"@
    }

    $group = $groups

    # Get the user
    $user = Get-MgUser -UserId $UserPrincipalName -ErrorAction SilentlyContinue

    if (-not $user) {
        throw "User '$UserPrincipalName' was not found."
    }

    # Remove the user from the group
    if ($PSCmdlet.ShouldProcess(
        "$($group.DisplayName) ($($group.Id))",
        "Remove member '$($user.UserPrincipalName)'"
    )) {
        Remove-MgGroupMemberByRef `
            -GroupId $group.Id `
            -DirectoryObjectId $user.Id
    }
}