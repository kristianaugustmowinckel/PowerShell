function New-HVLFolder {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FolderName
    )

    begin {

        $BasePath = "\\krn-fst-01\Data$"
        $LDAP     = "LDAP://krn-ad-01.hvl.no/dc=hvl,dc=no"
        $OU       = "OU=FST,OU=Filserver,OU=Grupper,OU=Brukere,DC=hvl,DC=no"

        $GroupBase = "G-HR-M-R-FST"

        $FolderPath = Join-Path $BasePath $FolderName

        $Groups = @(
            @{
                Name        = "U$GroupBase-Read-Data-$FolderName"
                Scope       = 'Universal'
                Description = "Read tilgang for Data\$FolderName"
            },
            @{
                Name        = "U$GroupBase-Modify-Data-$FolderName"
                Scope       = 'Universal'
                Description = "Modify tilgang for Data\$FolderName"
            },
            @{
                Name        = "L$GroupBase-Read-Data-$FolderName"
                Scope       = 'DomainLocal'
                Description = "Skal innehalde tilsvarande UG-gruppe"
            },
            @{
                Name        = "L$GroupBase-Modify-Data-$FolderName"
                Scope       = 'DomainLocal'
                Description = "Skal innehalde tilsvarande UG-gruppe"
            }
        )

        $UGRead   = $Groups[0].Name
        $UGModify = $Groups[1].Name
        $LGRead   = $Groups[2].Name
        $LGModify = $Groups[3].Name
    }

    process {

        try {

            foreach ($Group in $Groups) {

                if (-not (Test-ADObject -Type Group -SAMName $Group.Name -LDAP $LDAP)) {

                    if ($PSCmdlet.ShouldProcess($Group.Name, "Create AD group")) {

                        $Params = @{
                            Name             = $Group.Name
                            SamAccountName   = $Group.Name
                            DisplayName      = $Group.Name
                            Description      = $Group.Description
                            GroupCategory    = 'Security'
                            GroupScope       = $Group.Scope
                            Path             = $OU
                            ErrorAction      = 'Stop'
                        }

                        New-ADGroup @Params

                        Write-Verbose "Created $($Group.Name)"
                    }

                }
                else {
                    Write-Verbose "$($Group.Name) already exists."
                }

            }

            if ($PSCmdlet.ShouldProcess($LGRead, "Add $UGRead")) {

                Add-ADGroupMember -Identity $LGRead -Members $UGRead -ErrorAction SilentlyContinue
            }

            if ($PSCmdlet.ShouldProcess($LGModify, "Add $UGModify")) {

                Add-ADGroupMember -Identity $LGModify -Members $UGModify -ErrorAction SilentlyContinue
            }

            if (-not (Test-Path $FolderPath)) {

                if ($PSCmdlet.ShouldProcess($FolderPath, "Create folder")) {

                    New-Item -Path $FolderPath -ItemType Directory -ErrorAction Stop | Out-Null

                    $Acl = Get-Acl $FolderPath

                    $Rules = @(
                        @{
                            Identity     = $LGRead
                            Rights       = "ReadAndExecute, Synchronize"
                            Inheritance  = "ContainerInherit,ObjectInherit"
                            Propagation  = "None"
                        },
                        @{
                            Identity     = $LGModify
                            Rights       = "CreateFiles, AppendData, ReadAndExecute, Synchronize"
                            Inheritance  = "ContainerInherit,ObjectInherit"
                            Propagation  = "None"
                        },
                        @{
                            Identity     = $LGRead
                            Rights       = "ReadAndExecute, Synchronize"
                            Inheritance  = "ContainerInherit,ObjectInherit"
                            Propagation  = "InheritOnly"
                        },
                        @{
                            Identity     = $LGModify
                            Rights       = "DeleteSubdirectoriesAndFiles, Modify, ChangePermissions, Synchronize"
                            Inheritance  = "ContainerInherit,ObjectInherit"
                            Propagation  = "InheritOnly"
                        }
                    )

                    foreach ($Rule in $Rules) {

                        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                            $Rule.Identity,
                            $Rule.Rights,
                            [System.Security.AccessControl.InheritanceFlags]$Rule.Inheritance,
                            [System.Security.AccessControl.PropagationFlags]$Rule.Propagation,
                            [System.Security.AccessControl.AccessControlType]::Allow
                        )

                        $Acl.AddAccessRule($AccessRule)
                    }

                    Set-Acl -Path $FolderPath -AclObject $Acl

                    Write-Verbose "Folder created: $FolderPath"
                }

            }
            else {
                Write-Verbose "Folder already exists: $FolderPath"
            }

        }
        catch {
            Write-Error $_
        }

    }
}