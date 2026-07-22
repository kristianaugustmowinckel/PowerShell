function Get-RandomPassword {
    [CmdletBinding()]
    param(
        [ValidateRange(4,1024)]
        [int]$Length = 16,

        [switch]$Simple
    )

    $Lower   = "abcdefghijklmnopqrstuvwxyz".ToCharArray()
    $Upper   = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray()
    $Numbers = "0123456789".ToCharArray()
    $Special = '!@#$%^&*()-_=+[]{}<>?/.,;:'.ToCharArray()

    if ($Simple) {
        $CharacterSet = $Lower + $Upper + $Numbers
        return -join (1..$Length | ForEach-Object {
            $CharacterSet[[System.Security.Cryptography.RandomNumberGenerator]::GetInt32($CharacterSet.Count)]
        })
    }

    if ($Length -lt 4) {
        throw "Length must be at least 4 when using special characters."
    }

    # Ensure at least one of each category
    $PasswordChars = @(
        $Lower[[System.Security.Cryptography.RandomNumberGenerator]::GetInt32($Lower.Count)]
        $Upper[[System.Security.Cryptography.RandomNumberGenerator]::GetInt32($Upper.Count)]
        $Numbers[[System.Security.Cryptography.RandomNumberGenerator]::GetInt32($Numbers.Count)]
        $Special[[System.Security.Cryptography.RandomNumberGenerator]::GetInt32($Special.Count)]
    )

    $CharacterSet = $Lower + $Upper + $Numbers + $Special

    while ($PasswordChars.Count -lt $Length) {
        $PasswordChars += $CharacterSet[
            [System.Security.Cryptography.RandomNumberGenerator]::GetInt32($CharacterSet.Count)
        ]
    }

    # Fisher-Yates shuffle
    for ($i = $PasswordChars.Count - 1; $i -gt 0; $i--) {
        $j = [System.Security.Cryptography.RandomNumberGenerator]::GetInt32($i + 1)
        $tmp = $PasswordChars[$i]
        $PasswordChars[$i] = $PasswordChars[$j]
        $PasswordChars[$j] = $tmp
    }

    -join $PasswordChars
}