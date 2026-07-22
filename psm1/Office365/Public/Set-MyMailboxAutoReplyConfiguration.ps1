function Set-MyMailboxAutoReplyConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Mailbox,

        [Parameter(Mandatory)]
        [string]$Message
    )

    if ($PSCmdlet.ShouldProcess($Mailbox, "Configure automatic replies")) {

        Set-MailboxAutoReplyConfiguration `
            -Identity $Mailbox `
            -ExternalMessage $Message `
            -InternalMessage $Message `
            -AutoReplyState Enabled `
            -DeclineMeetingMessage $Message `
            -AutoDeclineFutureRequestsWhenOOF $true

        Get-MailboxAutoReplyConfiguration -Identity $Mailbox
    }
}