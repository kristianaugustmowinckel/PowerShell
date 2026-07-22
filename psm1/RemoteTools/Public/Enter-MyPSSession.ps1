function Enter-MyPSSession {
    [CmdletBinding(DefaultParameterSetName='Computer')]
    param(
        [Parameter(Mandatory, ParameterSetName='Computer')]
        [string]$ComputerName,

        [Parameter(Mandatory, ParameterSetName='Session')]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )

    if ($PSCmdlet.ParameterSetName -eq 'Computer') {
        $Session = New-MyPSSession -ComputerName $ComputerName
    }

    if ($Session) {
        Enter-PSSession -Session $Session
    }
}