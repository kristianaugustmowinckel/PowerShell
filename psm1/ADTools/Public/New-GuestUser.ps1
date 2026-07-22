 function New-GuestUser {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]

    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias("Name")]
        [ValidateNotNullOrEmpty()]
        [string]$FullName,

        [ValidateNotNullOrEmpty()]
        [string]$Prefix = "eks-",

        [string]$Description = "",

        [ValidateRange(1,3650)]
        [int]$Days = 365,

        [SecureString]$Password,

        [string]$Path = 'OU=Brukarar,OU="Lokal admin",OU=Datamaskiner,DC=hvl,DC=no'
    )

    process {

        # Split name
        $Parts = $FullName.Trim() -split '\s+'

        if ($Parts.Count -eq 1) {
            $GivenName = $Parts[0]
            $Surname   = $Parts[0]
        }
        else {
            $Surname   = $Parts[-1]
            $GivenName = ($Parts[0..($Parts.Count-2)] -join ' ')
        }

        $DisplayName = $FullName.Trim()

        #
        # Build username
        #

        if ($Parts.Count -eq 1) {

            $UserName = $Prefix + (Convert-Norwegian $GivenName).ToLower()

        }
        else {

            $GN = Convert-Norwegian $GivenName
            $SN = Convert-Norwegian $Surname

            $GNLength = [Math]::Min(2,$GN.Length)
            $SNLength = [Math]::Min(2,$SN.Length)

            $UserName = $Prefix +
                        $GN.Substring(0,$GNLength).ToLower() +
                        $SN.Substring(0,$SNLength).ToLower()
        }

        #
        # Ensure username is unique
        #

        $BaseUserName = $UserName
        $Counter = 1

        while (Get-ADUser -Filter "SamAccountName -eq '$UserName'" -ErrorAction SilentlyContinue) {

            $UserName = "$BaseUserName$Counter"
            $Counter++
        }

        $UPN = "$UserName@hvl.no"

        $ExpirationDate = (Get-Date).Date.AddDays($Days)

        $NewUser = @{
            Name                  = $DisplayName
            DisplayName           = $DisplayName
            GivenName             = $GivenName
            Surname               = $Surname
            SamAccountName        = $UserName
            UserPrincipalName     = $UPN
            Description           = $Description
            EmailAddress          = $UPN
            Path                  = $Path
            AccountExpirationDate = $ExpirationDate
            PassThru              = $true
        }

        if ($Password) {
            $NewUser.Enabled = $true
            $NewUser.AccountPassword = $Password
            $NewUser.ChangePasswordAtLogon = $true
        }

        if ($PSCmdlet.ShouldProcess($UserName,"Create guest account")) {

            try {

                $User = New-ADUser @NewUser -ErrorAction Stop

                Write-Verbose "Created account"

                Write-Verbose "Name        : $DisplayName"
                Write-Verbose "GivenName   : $GivenName"
                Write-Verbose "Surname     : $Surname"
                Write-Verbose "Username    : $UserName"
                Write-Verbose "UPN         : $UPN"
                Write-Verbose "Expires     : $ExpirationDate"

                $User

            }
            catch {

                Write-Error $_

            }

        }

    }

}