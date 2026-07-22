function Set-NewUserInfo {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]

    param(
        [Parameter(ParameterSetName = 'Display', Mandatory)]
        [string]$DisplayName,

        [Parameter(ParameterSetName = 'Sam', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Sam')]
        [string]$SamAccountName,

        [string]$Password = "AUTO",

        [switch]$PseudoRandomPassword,

        [switch]$SetPassword,

        [switch]$Employee
    )

    process {

        try {

            switch ($PSCmdlet.ParameterSetName) {

                'Display' {

                    $users = Get-ADUser `
                        -Filter "DisplayName -like '*$DisplayName*'" `
                        -Properties *

                    if ($Employee) {
                        $users = $users | Where-Object {
                            $_.SamAccountName -notmatch '\d'
                        }
                    }

                    if (-not $users) {
                        throw "No users found matching '$DisplayName'."
                    }

                    if ($users.Count -gt 1) {

                        Write-Warning "Multiple users matched."

                        $users |
                            Select-Object Name,
                                          SamAccountName,
                                          Mail

                        return
                    }

                    $user = $users
                }

                'Sam' {

                    if (-not (Test-ADObject -SAMName $SamAccountName -Type User)) {
                        throw "User '$SamAccountName' was not found."
                    }

                    $user = Get-ADUser `
                        -Identity $SamAccountName `
                        -Properties *
                }
            }

            if ($PseudoRandomPassword) {
                $Password = New-PseudoRandomPassword -BaseWord $Password
            }

            if ($Password.Length -lt 14) {
                throw "Password must contain at least 14 characters."
            }

            if ($Password -match [regex]::Escape($user.SamAccountName)) {
                throw "Password contains the username."
            }

            if ($SetPassword) {

                $SecurePassword = ConvertTo-SecureString `
                    $Password `
                    -AsPlainText `
                    -Force

                if ($PSCmdlet.ShouldProcess(
                        $user.SamAccountName,
                        "Reset Active Directory password")) {

                    Set-ADAccountPassword `
                        -Identity $user `
                        -Reset `
                        -NewPassword $SecurePassword
                }
            }

            [PSCustomObject]@{

                Name              = $user.Name
                DisplayName       = $user.DisplayName
                SamAccountName    = $user.SamAccountName
                UserPrincipalName = $user.UserPrincipalName
                Email             = $user.Mail
                Mobile            = ($user.OtherMobile -join ', ')
                Enabled           = $user.Enabled
                LastLogonDate     = $user.LastLogonDate
                Password          = $Password
                PasswordChanged   = $SetPassword.IsPresent
            }

        }
        catch {
            Write-Error $_
        }
    }
}