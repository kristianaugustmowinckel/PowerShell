function Get-MyM365GroupStatus {

    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Name
    )

    process {

        try {
            $group = Get-UnifiedGroup -Identity $Name -ErrorAction Stop
        }
        catch {
            Write-Warning "Microsoft 365 Group '$Name' was not found."
            return
        }

        #
        # Defaults
        #
        $sharingCapability = $null
        $allowToAddGuests  = $null

		#
		# SharePoint settings
		#
		if ($group.SharePointSiteUrl) {

		# Check if the SharePoint Online module is loaded
			if (Get-Module -Name Microsoft.Online.SharePoint.PowerShell) {

				$site = Get-SPOSite -Identity $group.SharePointSiteUrl -ErrorAction SilentlyContinue

				if ($site) {
					$sharingCapability = $site.SharingCapability
				}
			}
			else {
				Write-Verbose "SharePoint Online PowerShell module is not loaded. Skipping SharePoint settings."
			}
		}

        #
        # Microsoft Graph group settings
        #
        if ($group.ExternalDirectoryObjectId) {

            try {

                $settings = Get-MgGroupSetting -GroupId $group.ExternalDirectoryObjectId -ErrorAction Stop

                foreach ($setting in $settings.Values) {
                    if ($setting.Name -eq 'AllowToAddGuests') {
                        $allowToAddGuests = $setting.Value
                        break
                    }
                }

            }
            catch {
                # Group has no settings or Graph permissions missing
				Write-Error -Message "Group has no settings or Graph permissions missing"
            }
        }

        [PSCustomObject]@{

            DisplayName                           = $group.DisplayName
            Alias                                 = $group.Alias

            GroupType                             = $group.GroupType
            AccessType                            = $group.AccessType

            AutoSubscribeNewMembers               = $group.AutoSubscribeNewMembers
            AlwaysSubscribeMembersToCalendarEvents= $group.AlwaysSubscribeMembersToCalendarEvents
            SubscriptionEnabled                   = $group.SubscriptionEnabled
            WelcomeMessageEnabled                 = $group.WelcomeMessageEnabled

            IsMembershipDynamic                   = $group.IsMembershipDynamic

            AllowAddGuests                        = $group.AllowAddGuests
            AllowToAddGuests                      = $allowToAddGuests

            HiddenFromExchangeClientsEnabled      = $group.HiddenFromExchangeClientsEnabled
            HiddenFromAddressListsEnabled         = $group.HiddenFromAddressListsEnabled
            HiddenGroupMembershipEnabled          = $group.HiddenGroupMembershipEnabled
            RequireSenderAuthenticationEnabled    = $group.RequireSenderAuthenticationEnabled

            SharingCapability                     = $sharingCapability

            ModerationEnabled                     = $group.ModerationEnabled
            BypassModerationFromSendersOrMembers  = $group.BypassModerationFromSendersOrMembers
            ModeratedBy                           = $group.ModeratedBy

            ManagedBy                             = $group.ManagedBy
            GroupMemberCount                      = $group.GroupMemberCount
            SharePointSiteUrl                     = $group.SharePointSiteUrl

            CustomAttribute1                      = $group.CustomAttribute1
            CustomAttribute2                      = $group.CustomAttribute2
            CustomAttribute3                      = $group.CustomAttribute3
        }
    }
}