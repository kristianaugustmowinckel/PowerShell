function Set-MyAclOwner {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][string]$User,
        [Parameter(Mandatory)][string]$Path
    )

    try {
        if (-not (Test-Path -LiteralPath $Path)) {
            throw "Path not found."
        }

        $acl = Get-Acl -LiteralPath $Path
        $acl.SetOwner([System.Security.Principal.NTAccount]$User)

        if ($PSCmdlet.ShouldProcess($Path, "Set owner")) {
            Set-Acl -LiteralPath $Path -AclObject $acl
        }

        $true
    }
    catch {
        Write-Error $_
        $false
    }
}