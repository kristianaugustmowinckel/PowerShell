function Invoke-ReSubscribeGroup {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(ParameterSetName = 'List')]
        [switch]$ListNotSubscribed,

        [Parameter(ParameterSetName = 'Subscribe')]
        [switch]$SubscribeAll,

        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [Alias('Identity')]
        [string[]]$Name
    )

    process {

        try {
            if ($Name) {
                $Groups = foreach ($GroupName in $Name) {
                    Get-UnifiedGroup -Identity $GroupName -ErrorAction Stop
                }
            }
            else {
                Write-Verbose "Retrieving all mail list groups..."
                $Groups = Get-UnifiedGroup -ResultSize Unlimited -ErrorAction Stop |
                    Where-Object { $_.CustomAttribute2 -like 'Mailliste*' }
            }
        }
        catch {
            Write-Error "Failed to retrieve groups. $_"
            return
        }

        foreach ($Group in $Groups) {

            Write-Verbose "Processing group '$($Group.DisplayName)'"

            try {
                $Members = Get-UnifiedGroupLinks -Identity $Group.Identity `
                    -LinkType Members `
                    -ResultSize Unlimited `
                    -ErrorAction Stop

                $Subscribers = Get-UnifiedGroupLinks -Identity $Group.Identity `
                    -LinkType Subscribers `
                    -ResultSize Unlimited `
                    -ErrorAction Stop
            }
            catch {
                Write-Warning "Could not retrieve links for '$($Group.DisplayName)': $_"
                continue
            }

            # Build a fast lookup table
            $SubscriberLookup = @{}
            foreach ($Subscriber in $Subscribers) {
                $SubscriberLookup[$Subscriber.ExternalDirectoryObjectId] = $true
            }

            foreach ($Member in $Members) {

                if (-not $SubscriberLookup.ContainsKey($Member.ExternalDirectoryObjectId)) {

                    $Result = [PSCustomObject]@{
                        Group        = $Group.DisplayName
                        Member       = $Member.DisplayName
                        Alias        = $Member.Alias
                        PrimarySmtp  = $Member.PrimarySmtpAddress
                        ActionNeeded = 'Subscribe'
                    }

                    if ($ListNotSubscribed) {
                        $Result
                    }

                    if ($SubscribeAll) {

                        if ($PSCmdlet.ShouldProcess(
                                "$($Member.DisplayName)",
                                "Subscribe to '$($Group.DisplayName)'")) {

                            try {
                                Add-UnifiedGroupLinks `
                                    -Identity $Group.Identity `
                                    -LinkType Subscribers `
                                    -Links $Member.Identity `
                                    -ErrorAction Stop

                                Write-Verbose "Subscribed $($Member.DisplayName)"
                                $Result
                            }
                            catch {
                                Write-Warning "Failed to subscribe $($Member.DisplayName): $_"
                            }
                        }
                    }
                }
            }
        }
    }
}