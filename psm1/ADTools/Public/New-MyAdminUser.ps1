function New-TemporaryLocalAdmin {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$SamAccountName,

        [Parameter(Mandatory)]
        [string]$INC,

        [string]$ComputerName,

        [int]$DaysToExpire = 100,

        [string]$BasePassword = "OwlSnakePalmtree"
    )

    # Lookup user
    $User = Get-ADUser -Identity $SamAccountName -Properties GivenName,Surname,DisplayName,SamAccountName -ErrorAction Stop

    # Determine computer group
    if ($User.SamAccountName -match '\d') {
        $ComputerGroup = 'UG-HR-M-R-GPO-Student-ComputersWithLocalAdmins'
    }
    else {
        $ComputerGroup = 'UG-HR-M-R-GPO-Tilsett-ComputersWithLocalAdmins'
    }

    # Build admin account information
    $AdminSam = "$($User.SamAccountName)-cadm"
    $Password = New-PseudoRandomPassword -BaseWord $BasePassword
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

    if ($PSCmdlet.ShouldProcess($AdminSam, "Create temporary admin account")) {

        if (-not (Get-ADUser -Filter "SamAccountName -eq '$AdminSam'" -ErrorAction SilentlyContinue)) {

            New-ADUser `
                -Name "[CADM] $($User.DisplayName)" `
                -SamAccountName $AdminSam `
                -UserPrincipalName "$AdminSam@hvl.no" `
                -GivenName "[CADM] $($User.GivenName)" `
                -Surname $User.Surname `
                -DisplayName "[CADM] $($User.DisplayName)" `
                -Enabled $true `
                -AccountPassword $SecurePassword `
                -ChangePasswordAtLogon $true `
                -AccountExpirationDate (Get-Date).AddDays($DaysToExpire) `
                -Description "Lokal adminkonto for $($User.DisplayName); INC $INC" `
                -Path 'OU=Brukarar,OU="Lokal admin",OU=Datamaskiner,DC=hvl,DC=no'
        }

        Add-ADGroupMember -Identity 'CADM-LokalAdmin' -Members $AdminSam

        if ($ComputerName) {
            Add-ADGroupMember -Identity $ComputerGroup -Members "$ComputerName`$"
        }

        [PSCustomObject]@{
            AdminAccount = $AdminSam
            Password     = $Password
            Expires      = (Get-Date).AddDays($DaysToExpire)
            Computer     = $ComputerName
        }
    }
}