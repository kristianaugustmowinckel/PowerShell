function New-MyM365Group {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [string]$CustomAttribute1,

        [ValidateSet("Mailliste","MaillisteSAP","Other")]
        [string]$CustomAttribute2 = "Mailliste",

        [string]$CustomAttribute3,

        [int]$ProvisionTimeout = 300,

        [switch]$CreateGroup,

        [switch]$AllowToAddGuestsFalse,

        [switch]$SharingCapabilityDisabled,

        [switch]$DoNOTResubscribeGroups
    )

    begin {

        $NameAscii = Convert-Norwegian -String $Name
        $PrimarySmtpAddress = "$NameAscii@hvl.no"

        Write-Verbose "Checking whether '$Name' already exists..."

        $Group = Get-UnifiedGroup -Identity $PrimarySmtpAddress -ErrorAction SilentlyContinue

    }

    process {

        if ($Group) {
            Write-Warning "Group '$Name' already exists."
            return $Group
        }

        if (-not $CreateGroup) {
            Write-Verbose "CreateGroup switch not specified."
            return
        }

        if ($PSCmdlet.ShouldProcess($Name,"Create Microsoft 365 Group")) {

            try {

                Write-Verbose "Creating group..."

                New-UnifiedGroup `
                    -Name $NameAscii `
                    -DisplayName $Name `
                    -Alias $NameAscii `
                    -PrimarySmtpAddress $PrimarySmtpAddress `
                    -AccessType Private `
                    -ErrorAction Stop

            }
            catch {
                throw "Unable to create group '$Name'. $_"
            }

            #
            # Wait until provisioning completes
            #
            Write-Verbose "Waiting for Exchange provisioning..."

            $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()

            do {

                Start-Sleep -Seconds 5

                $Group = Get-UnifiedGroup `
                    -Identity $PrimarySmtpAddress `
                    -ErrorAction SilentlyContinue

            } until ($Group -or $StopWatch.Elapsed.TotalSeconds -ge $ProvisionTimeout)

            if (-not $Group) {
                throw "Group provisioning timed out."
            }

            #
            # Build Set-UnifiedGroup parameters
            #
            $SetParams = @{
                Identity                               = $PrimarySmtpAddress
                AutoSubscribeNewMembers                = $true
                AlwaysSubscribeMembersToCalendarEvents = $true
                SubscriptionEnabled                    = $true
                UnifiedGroupWelcomeMessageEnabled      = $false
                HiddenFromExchangeClientsEnabled       = $false
            }

            if ($CustomAttribute1) {
                $SetParams.CustomAttribute1 = $CustomAttribute1
            }

            if ($CustomAttribute2) {
                $SetParams.CustomAttribute2 = $CustomAttribute2
            }

            if ($CustomAttribute3) {
                $SetParams.CustomAttribute3 = $CustomAttribute3
            }

            Write-Verbose "Applying group settings..."

            Set-UnifiedGroup @SetParams

            #
            # Future Graph implementation
            #
            if ($AllowToAddGuestsFalse) {
                Write-Verbose "Guest access restriction requested (not yet implemented)."
            }

            if ($SharingCapabilityDisabled) {
                Write-Verbose "SharePoint sharing restriction requested (not yet implemented)."
            }

            if (-not $DoNOTResubscribeGroups) {

                Write-Verbose "Running Invoke-ReSubscribeGroups..."

                Invoke-ReSubscribeGroups `
                    -SubscribeAll `
                    -Name $Name
            }

            #
            # Return newly created object
            #
            Get-UnifiedGroup -Identity $PrimarySmtpAddress
        }

    }

    end {}
}