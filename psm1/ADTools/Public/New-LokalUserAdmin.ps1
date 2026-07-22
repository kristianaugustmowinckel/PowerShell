function New-LokalUserAdmin {

    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]

    param(
        [Parameter(Mandatory)]
        [string]$Sam
    )

    begin {
        $Description = "Konto for lokal pålogging Arbeidsstasjoner"
        $OU          = "OU=Brukere,OU=Mgmt,OU=Datamaskiner,DC=hvl,DC=no"
        $Password    = ConvertTo-SecureString "Bergen1814" -AsPlainText -Force
    }

    process {

        try {
            $User = Get-ADUser -Identity $Sam -Properties DisplayName,GivenName,Surname -ErrorAction Stop
        }
        catch {
            Write-Error "User '$Sam' was not found."
            return
        }

        $NewSam = "$($User.SamAccountName)-lokal"

        if (Get-ADUser -Filter "SamAccountName -eq '$NewSam'" -ErrorAction SilentlyContinue) {
            Write-Warning "Account '$NewSam' already exists."
            return
        }

        $params = @{
            Name                  = "[CMGMT] $($User.DisplayName)"
            DisplayName           = "[CMGMT] $($User.DisplayName)"
            GivenName             = "[CMGMT] $($User.GivenName)"
            Surname               = $User.Surname
            Description           = $Description
            SamAccountName        = $NewSam
            UserPrincipalName     = "$NewSam@hvl.no"
            AccountPassword       = $Password
            Path                  = $OU
            Enabled               = $true
            PasswordNeverExpires  = $true
            ChangePasswordAtLogon = $false
        }

        if ($PSCmdlet.ShouldProcess($NewSam, "Create local admin account")) {
            New-ADUser @params
            Write-Verbose "Created $NewSam"
        }
    }
}