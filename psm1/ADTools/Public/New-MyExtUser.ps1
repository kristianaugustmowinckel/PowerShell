function New-MyExtUser {

    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]

    param(
        [Parameter(Mandatory)]
        [string]$SamAccountName,

        [ValidateRange(1,3650)]
        [int]$DaysToExpire = 365,

        [string]$BasePassword = 'OwlSnakePalmtree'
    )

    begin {

        $Prefix = 'eks-'
        $DescriptionPrefix = 'Konto for ekstern bruker '
        $UserPath = 'OU=MGMT,OU=Datamaskiner,DC=hvl,DC=no'

    }

    process {

        #
        # Try to find an existing HVL user
        #

        $SourceUser = Get-ADUser `
            -Identity $SamAccountName `
            -Properties GivenName,Surname,DisplayName `
            -ErrorAction SilentlyContinue

        if ($SourceUser) {

            $GivenName   = $SourceUser.GivenName
            $Surname     = $SourceUser.Surname
            $DisplayName = $SourceUser.DisplayName

        }
        else {

            Write-Verbose "User '$SamAccountName' not found."

            $GivenName = Read-Host "Given name"
            $Surname   = Read-Host "Surname"

            $DisplayName = "$GivenName $Surname"
        }

        #
        # Build new account
        #

        $NewSamAccountName = "$Prefix$SamAccountName"

        if (Get-ADUser -Identity $NewSamAccountName -ErrorAction SilentlyContinue) {
            throw "The account '$NewSamAccountName' already exists."
        }

        $Name                  = "$DisplayName ($NewSamAccountName)"
        $UserPrincipalName     = "$NewSamAccountName@hvl.no"
        $Description           = "$DescriptionPrefix$DisplayName"
        $PlainPassword         = New-PseudoRandomPassword -BaseWord $BasePassword
        $SecurePassword        = ConvertTo-SecureString $PlainPassword -AsPlainText -Force
        $AccountExpirationDate = (Get-Date).Date.AddDays($DaysToExpire)

        $Params = @{
            Name                  = $Name
            GivenName             = $GivenName
            Surname               = $Surname
            DisplayName           = $DisplayName
            SamAccountName        = $NewSamAccountName
            UserPrincipalName     = $UserPrincipalName
            Description           = $Description
            Path                  = $UserPath
            Enabled               = $true
            ChangePasswordAtLogon = $true
            AccountPassword       = $SecurePassword
            AccountExpirationDate = $AccountExpirationDate
        }

        if ($PSCmdlet.ShouldProcess($NewSamAccountName,'Create external AD user')) {

            New-ADUser @Params

            $NewUser = Get-ADUser -Identity $NewSamAccountName

            [PSCustomObject]@{
                UserName               = $NewUser.SamAccountName
                DisplayName            = $DisplayName
                Password               = $PlainPassword
                UserPrincipalName      = $UserPrincipalName
                DistinguishedName      = $NewUser.DistinguishedName
                ExpirationDate         = $AccountExpirationDate
                ChangePasswordAtLogon  = $true
                Enabled                = $true
            }
        }
    }
}