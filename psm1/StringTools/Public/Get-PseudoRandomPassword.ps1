function Get-PseudoRandomPassword {
    [CmdletBinding()]
	[OutputType([string])]
    param(
        [string]$BaseWord = 'KattHundDue',

        [ValidateRange(1,999999)]
        [int]$MinNumber = 1000,

        [ValidateRange(2,1000000)]
        [int]$MaxNumber = 9999
    )

    if ($MinNumber -gt $MaxNumber) {
        throw "MinNumber kan ikke være større enn MaxNumber."
    }

    "$BaseWord$(Get-Random -Minimum $MinNumber -Maximum ($MaxNumber + 1))"
}