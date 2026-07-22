function Set-MyAclUser {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string]$User,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        [string]$Directory,

        [switch]$Full
    )

    try {
        $acl = Get-Acl -Path $Directory

        $inheritance = [System.Security.AccessControl.InheritanceFlags]'ContainerInherit,ObjectInherit'

        #
        # Rule applied to the folder itself
        #
        if ($Full) {
            $rights = [System.Security.AccessControl.FileSystemRights]::Modify `
                    -bor [System.Security.AccessControl.FileSystemRights]::ChangePermissions `
                    -bor [System.Security.AccessControl.FileSystemRights]::Synchronize `
                    -bor [System.Security.AccessControl.FileSystemRights]::DeleteSubdirectoriesAndFiles
        }
        else {
            $rights = [System.Security.AccessControl.FileSystemRights]::CreateFiles `
                    -bor [System.Security.AccessControl.FileSystemRights]::AppendData `
                    -bor [System.Security.AccessControl.FileSystemRights]::ReadAndExecute `
                    -bor [System.Security.AccessControl.FileSystemRights]::Synchronize
        }

        $rule = [System.Security.AccessControl.FileSystemAccessRule]::new(
            $User,
            $rights,
            $inheritance,
            [System.Security.AccessControl.PropagationFlags]::None,
            [System.Security.AccessControl.AccessControlType]::Allow
        )

        $null = $acl.AddAccessRule($rule)

        #
        # Rule inherited by child objects
        #
        $childRights = [System.Security.AccessControl.FileSystemRights]::Modify `
                     -bor [System.Security.AccessControl.FileSystemRights]::ChangePermissions `
                     -bor [System.Security.AccessControl.FileSystemRights]::Synchronize `
                     -bor [System.Security.AccessControl.FileSystemRights]::DeleteSubdirectoriesAndFiles

        $childRule = [System.Security.AccessControl.FileSystemAccessRule]::new(
            $User,
            $childRights,
            $inheritance,
            [System.Security.AccessControl.PropagationFlags]::InheritOnly,
            [System.Security.AccessControl.AccessControlType]::Allow
        )

        $null = $acl.AddAccessRule($childRule)

        if ($PSCmdlet.ShouldProcess($Directory, "Grant permissions to '$User'")) {
            Set-Acl -Path $Directory -AclObject $acl
        }

        return $true
    }
    catch {
        Write-Error $_
        return $false
    }
}