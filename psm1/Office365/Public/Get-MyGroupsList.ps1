function Get-MyGroupsList {

    [CmdletBinding()]
    param(
        [string]$Filter,

        [string]$NameFilter,

        [switch]$Distribution,

        [switch]$Unified
    )

    begin {

        $OutputFolder = ".\RS"

        if (!(Test-Path $OutputFolder)) {
            New-Item -ItemType Directory -Path $OutputFolder | Out-Null
        }

    }

    process {

        ############################################################
        # Distribution Groups
        ############################################################

        if ($Distribution) {

            $FileName = "distributionlists"

            if ([string]::IsNullOrWhiteSpace($Filter)) {

                $FileName += "-all"

                $DistributionGroups = Get-DistributionGroup -ResultSize Unlimited |
                    Sort-Object DisplayName
            }
            else {

                $FileName += "-filtered"

                $DistributionGroups = Get-DistributionGroup `
                    -Filter "CustomAttribute2 -like '$Filter'" `
                    -ResultSize Unlimited

                if ($NameFilter) {
                    $DistributionGroups = $DistributionGroups |
                        Where-Object Name -like $NameFilter
                }

                $DistributionGroups = $DistributionGroups |
                    Sort-Object DisplayName
            }

            # Summary report

            $DistributionGroups |
                Select-Object DisplayName,
                @{Name='Alias';Expression={$_.PrimarySmtpAddress -replace '@hvl.no',''}},
                Name,
                CustomAttribute2,
                ManagedBy |
                Format-Table -AutoSize |
                Out-File (Join-Path $OutputFolder "$FileName-short.txt") -Encoding utf8

            # Detailed report

            $DetailedReport = foreach ($Group in $DistributionGroups) {

                $Members = Get-DistributionGroupMember `
                    -Identity $Group.PrimarySmtpAddress `
                    -ResultSize Unlimited |
                    Sort-Object DisplayName |
                    Select-Object DisplayName,
                                  Alias,
                                  Name,
                                  PrimarySmtpAddress,
                                  Title,
                                  Department,
                                  Company,
                                  Office,
                                  CustomAttribute2,
                                  CustomAttribute3

                $Group.DisplayName

                $Group |
                    Select-Object DisplayName,
                                  Alias,
                                  Name,
                                  PrimarySmtpAddress,
                                  CustomAttribute1,
                                  CustomAttribute2,
                                  CustomAttribute3 |
                    Format-Table -AutoSize

                "Members:"

                $Members | Format-Table -AutoSize

                ""
            }

            $DetailedReport |
                Out-File (Join-Path $OutputFolder "$FileName-long.txt") -Encoding utf8

        }

        ############################################################
        # Unified Groups
        ############################################################

        if ($Unified) {

            $FileName = "unifiedgroups"

            if ([string]::IsNullOrWhiteSpace($Filter)) {

                $FileName += "-all"

                $UnifiedGroups = Get-UnifiedGroup -ResultSize Unlimited

            }
            else {

                $FileName += "-filtered"

                $UnifiedGroups = Get-UnifiedGroup -ResultSize Unlimited |
                    Where-Object CustomAttribute2 -like $Filter

                if ($NameFilter) {
                    $UnifiedGroups = $UnifiedGroups |
                        Where-Object Name -like $NameFilter
                }
            }

            #
            # Summary
            #

            $UnifiedGroups |
                Select-Object `
                    @{Name='Navn';Expression={$_.DisplayName}},
                    @{Name='Medlemskapstype';Expression={
                        if ($_.IsMembershipDynamic) {
                            "AUTOMATISK"
                        }
                        else {
                            "MANUELL"
                        }
                    }},
                    @{Name='Eigarar';Expression={
                        if ($_.IsMembershipDynamic) {
                            "SYSTEM"
                        }
                        else {
                            (Get-UnifiedGroupLinks -Identity $_.Identity -LinkType Owner |
                                Select-Object -Expand DisplayName) -join ", "
                        }
                    }} |
                Sort-Object Medlemskapstype, Navn |
                Export-Excel `
                    -Path (Join-Path $OutputFolder "$FileName.xlsx") `
                    -AutoSize `
                    -FreezeTopRow `
                    -FreezeFirstColumn `
                    -BoldTopRow

            #
            # Members
            #

            $AllMembers = foreach ($Group in $UnifiedGroups) {

                Get-UnifiedGroupLinks `
                    -Identity $Group.Identity `
                    -LinkType Member `
                    -ResultSize Unlimited |

                    Select-Object `
                        @{Name='GroupDisplayName';Expression={$Group.DisplayName}},
                        DisplayName,
                        Alias,
                        Title,
                        Department,
                        Company,
                        CustomAttribute3
            }

            $AllMembers |
                Sort-Object GroupDisplayName, DisplayName |
                Export-Excel `
                    -Path (Join-Path $OutputFolder "$FileName-members.xlsx") `
                    -AutoSize `
                    -FreezeTopRow `
                    -FreezeFirstColumn `
                    -BoldTopRow
        }
    }
}