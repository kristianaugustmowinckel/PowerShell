function Get-MyRecipientStat {
    [CmdletBinding()]
    param()

    $mailContacts = foreach ($contact in Get-MailContact -ResultSize Unlimited) {

        $primaryAddress = "smtp:$($contact.PrimarySmtpAddress)"

        $addresses = $contact.EmailAddresses |
            Where-Object {
                $_ -notmatch '^(sip|spo|x500):' -and
                $_ -notmatch '@HVL365\.mail\.onmicrosoft\.com$' -and
                $_ -ne $primaryAddress
            } |
            ForEach-Object {
                $_ -replace '^smtp:', ''
            }

        $obj = $contact.PSObject.Copy()

        $obj | Add-Member -NotePropertyName AddressCount -NotePropertyValue $addresses.Count -Force
        $obj | Add-Member -NotePropertyName MAddresses   -NotePropertyValue ($addresses -join ';') -Force

        $obj
    }

    $mailContacts | Sort-Object RecipientType, DisplayName
}