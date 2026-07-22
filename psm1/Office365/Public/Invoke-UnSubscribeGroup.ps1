function Invoke-UnsubscribeGroup {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium',
        DefaultParameterSetName = 'List'
    )]
    param(
        [Parameter(ParameterSetName = 'List')]
        [switch]$List,

        [Parameter(ParameterSetName = 'Unsubscribe')]
        [switch]$Unsubscribe,

        [string]$Name
    )

    try {
        if ($Name) {
            $Groups = Get-UnifiedGroup -Identity $Name -ErrorAction Stop
        }
        else {
            $Groups = Get-UnifiedGroup -ResultSize Unlimited |
                Where-Object { $_.CustomAttribute2 -like 'Mailliste*' }
        }

        foreach ($Group in $Groups) {

            Write-Verbose "Processing group '$($Group.DisplayName)'"

            $Members = Get-UnifiedGroupLinks `
                -Identity $Group.Identity `
                -LinkType Members `
                -ResultSize Unlimited

            $Subscribers = Get-UnifiedGroupLinks `
                -Identity $Group.Identity `
                -LinkType Subscribers `
                -ResultSize Unlimited

            # Build lookup table for subscribers
            $SubscriberLookup = @{}

            foreach ($Subscriber in $Subscribers) {
                $SubscriberLookup[$Subscriber.ExternalDirectoryObjectId] = $Subscriber
            }

            foreach ($Member in $Members) {

                if ($SubscriberLookup.ContainsKey($Member.ExternalDirectoryObjectId)) {

                    $Message = "{0}: {1} ({2})" -f `
                        $Group.DisplayName,
                        $Member.DisplayName,
                        $Member.PrimarySmtpAddress

                    if ($List) {
                        Write-Output $Message
                    }

                    if ($Unsubscribe) {

                        if ($PSCmdlet.ShouldProcess(
                                $Member.DisplayName,
                                "Remove subscriber from '$($Group.DisplayName)'"
                            )) {

                            Remove-UnifiedGroupLinks `
                                -Identity $Group.Identity `
                                -LinkType Subscribers `
                                -Links $Member.PrimarySmtpAddress `
                                -Confirm:$false

                            Write-Output $Message
                        }
                    }
                }
            }
        }
    }
    catch {
        Write-Error $_
    }
}