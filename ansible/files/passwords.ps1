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

    $password
}

$users = Import-Csv ./ansible/files/character-deaths.csv

$header = "name,account_name,group,password"

$accountfile = "./ansible/files/accounts.csv"
$groupfile = "./ansible/files/groups.txt"

$account_array = @()
$group_array = @()

$account_array += $header

foreach ($user in $users)
{
    $account_name=$user.name.ToLower()
    $account_name= $account_name -replace "(",''
    $account_name= $account_name -replace ")",''
    $account_name= $account_name -replace '\s','.'
    $group_name=$user.allegiances.ToLower()
    $group_name=$group_name -replace '\s','_'
    
    $pw=GeneratePassword(12)
    $row = "{0},{1},{2},{3}" -f $user.name, $account_name, $group_name, $pw
    $account_array += $row
}

$groups = $users | Select-Object -Property Allegiances -Unique
foreach($group in $groups)
{
    if($group.Allegiances)
    {
        $group_name = $group.Allegiances.ToLower()
        $group_name = $group_name -replace '\s','_'
        $group_array += $group_name
    }
}

$account_array | Out-File $accountfile
$group_array | Out-File $groupfile