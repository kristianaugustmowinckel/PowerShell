function New-MyDistributionGroup {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [string]$DisplayName,

        [string]$Alias,

        [string]$PrimarySmtpAddress,

        [bool]$RequireSenderAuthenticationEnabled = $true
    )

    # Convert Norwegian characters
    $NameAscii = Convert-Norwegian -String $Name

    if ([string]::IsNullOrWhiteSpace($DisplayName)) {
        $DisplayName = $Name
    }

    if ([string]::IsNullOrWhiteSpace($Alias)) {
        $Alias = $NameAscii
    }

    if ([string]::IsNullOrWhiteSpace($PrimarySmtpAddress)) {
        $PrimarySmtpAddress = "$NameAscii@hvl.no"
    }

    $AdditionalAddresses = @(
        "$NameAscii@HVL365.onmicrosoft.com"
        "$NameAscii@HVL365.mail.onmicrosoft.com"
    )

    # Check if group already exists
    $Group = Get-DistributionGroup -Identity $PrimarySmtpAddress -ErrorAction SilentlyContinue

    if ($Group) {
        Write-Error "A distribution group with the address '$PrimarySmtpAddress' already exists."
        return
    }

    if ($PSCmdlet.ShouldProcess($PrimarySmtpAddress, "Create Distribution Group")) {

        try {
            $Group = New-DistributionGroup `
                -Name $Name `
                -DisplayName $DisplayName `
                -Alias $Alias `
                -PrimarySmtpAddress $PrimarySmtpAddress `
                -RequireSenderAuthenticationEnabled $RequireSenderAuthenticationEnabled `
                -ErrorAction Stop

            Write-Verbose "Distribution group created."

            Set-DistributionGroup `
                -Identity $Group.Identity `
                -EmailAddresses @{Add = $AdditionalAddresses} `
                -CustomAttribute2 "MailListe" `
                -ErrorAction Stop

            Write-Verbose "Additional email addresses added."
            Write-Verbose "CustomAttribute2 set to 'MailListe'."

            return Get-DistributionGroup -Identity $Group.Identity
        }
        catch {
            Write-Error "Failed to create distribution group '$Name'. $($_.Exception.Message)"
        }
    }
}