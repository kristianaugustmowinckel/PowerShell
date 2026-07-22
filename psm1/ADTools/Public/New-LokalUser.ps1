function New-LokalUser {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$SamAccountName
    )

    begin {
        $Description = "Konto for lokal pålogging Arbeidsstasjoner"
        $OU = "OU=Brukere,OU=Mgmt,OU=Datamaskiner,DC=hvl,DC=no"
        $Password = ConvertTo-SecureString "Bergen1814" -AsPlainText -Force
    }

    process {

        if (Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue) {
            Write-Warning "User '$SamAccountName' already exists."
            return
        }

        $params = @{
            SamAccountName    = $SamAccountName
            UserPrincipalName = "$SamAccountName@hvl.no"
            Name              = $SamAccountName
            DisplayName       = $SamAccountName
            GivenName         = $SamAccountName
            Surname           = $SamAccountName
            Description       = $Description
            Path              = $OU
            AccountPassword   = $Password
            Enabled           = $true
            ChangePasswordAtLogon = $false
            PasswordNeverExpires  = $true
        }

        if ($PSCmdlet.ShouldProcess($SamAccountName, "Create Active Directory user")) {

            New-ADUser @params

            Write-Verbose "Created user '$SamAccountName'."

            Get-ADUser $SamAccountName
        }
    }
}