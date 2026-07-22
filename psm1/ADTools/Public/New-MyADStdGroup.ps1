function New-MyADStdGroup {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Type = "HR-M-R",

        [Parameter()]
        [switch]$AppLocker,

        [Parameter()]
        [string]$Server = "krn-ad-02.hvl.no",

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Path = "OU=Grupper,OU=Brukere,DC=hvl,DC=no",

        [Parameter()]
        [string]$Description
    )

    process {

        $commonName = if ($AppLocker) {
            "G-$Type-Applocker-Allow-$Name"
        }
        else {
            "G-$Type-$Name"
        }

        $localGroup = "L$commonName"
        $universalGroup = "U$commonName"

        if ($AppLocker) {
            if ([string]::IsNullOrWhiteSpace($Description)) {
                $Description = "Gruppe som tillater alle exe/script å køyre av AppLocker."
            }
            else {
                $Description = "Gruppe som tillater alle exe/script å køyre av AppLocker i $Description"
            }
        }

        try {

            $lGroup = Get-ADGroup -Server $Server -Filter "SamAccountName -eq '$localGroup'" -ErrorAction SilentlyContinue
            $uGroup = Get-ADGroup -Server $Server -Filter "SamAccountName -eq '$universalGroup'" -ErrorAction SilentlyContinue

            if (-not $lGroup) {

                if ($PSCmdlet.ShouldProcess($localGroup, "Create Domain Local group")) {

                    $lGroup = New-ADGroup `
                        -Server $Server `
                        -Name $localGroup `
                        -SamAccountName $localGroup `
                        -DisplayName $localGroup `
                        -GroupCategory Security `
                        -GroupScope DomainLocal `
                        -Path $Path `
                        -Description $Description `
                        -PassThru

                    Write-Verbose "Created $localGroup"
                }
            }
            else {
                Write-Verbose "$localGroup already exists."
            }

            if (-not $uGroup) {

                if ($PSCmdlet.ShouldProcess($universalGroup, "Create Universal group")) {

                    $uGroup = New-ADGroup `
                        -Server $Server `
                        -Name $universalGroup `
                        -SamAccountName $universalGroup `
                        -DisplayName $universalGroup `
                        -GroupCategory Security `
                        -GroupScope Universal `
                        -Path $Path `
                        -Description $Description `
                        -PassThru

                    Write-Verbose "Created $universalGroup"
                }
            }
            else {
                Write-Verbose "$universalGroup already exists."
            }

            # Ensure Universal is member of Local
            if ($lGroup -and $uGroup) {

                $isMember = Get-ADGroupMember -Server $Server -Identity $lGroup |
                    Where-Object DistinguishedName -eq $uGroup.DistinguishedName

                if (-not $isMember) {

                    if ($PSCmdlet.ShouldProcess($localGroup, "Add $universalGroup as member")) {

                        Add-ADGroupMember `
                            -Server $Server `
                            -Identity $lGroup `
                            -Members $uGroup `
                            -Confirm:$false

                        Write-Verbose "Added $universalGroup to $localGroup"
                    }
                }
                else {
                    Write-Verbose "$universalGroup is already a member of $localGroup."
                }
            }

            # Return the created/existing groups
            [PSCustomObject]@{
                LocalGroup     = $localGroup
                UniversalGroup = $universalGroup
                Description    = $Description
                Server         = $Server
            }

        }
        catch {
            Write-Error "Failed to create or configure AD groups '$localGroup' and '$universalGroup'. $($_.Exception.Message)"
        }
    }
}