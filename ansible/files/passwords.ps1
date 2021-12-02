# https://dev.to/onlyann/user-password-generation-in-powershell-core-1g91
$symbols = '!@#$%^&*'.ToCharArray()
$characterList = 'a'..'z' + 'A'..'Z' + '0'..'9' + $symbols

function GeneratePassword {
    param(
        [ValidateRange(12, 256)]
        [int] 
        $length = 14
    )

    do {
        $password = -join (0..$length | % { $characterList | Get-Random })
        [int]$hasLowerChar = $password -cmatch '[a-z]'
        [int]$hasUpperChar = $password -cmatch '[A-Z]'
        [int]$hasDigit = $password -match '[0-9]'
        [int]$hasSymbol = $password.IndexOfAny($symbols) -ne -1

    }
    until (($hasLowerChar + $hasUpperChar + $hasDigit + $hasSymbol) -ge 3)

    $password | ConvertTo-SecureString -AsPlainText
}

$users = Import-Csv ./files/character-deaths.csv

$header = "name,account_name,group,password"

$accountfile = "accounts.csv"
$groupfile = "groups.txt"

$account_array = @()
$group_array = @()

$account_array += $header

foreach ($user in $users)
{
    Write-Host $user.name
}