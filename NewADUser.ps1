# This script creates active directory users based on the contents of a csv file with the structure shown on the next two lines.
# userLogonName;firstName;lastName;OU;securityGroup
# Euan;Euan;Cockburn;utilisateurs;etudiants

# It's parameters are the delimiter of the csv file (the default is ;) the path of the csv file with the users to be created 
# and the path of the folder in which to output the csv containing the result of the operation including the password assigned
# to any new users

param($path,$delimiter=';',$exportFolder)
$exportPath = $exportFolder + (Get-Date -Format "yyyy-MM-dd-HH-mm") + '.csv'
 
$csv = Import-Csv -Delimiter $delimiter -Path $path
$export = $csv | Select-Object *,"initialPassword" | Select-Object *, "existsAlready"
$export | Format-Table

# function which generates a paswword of a length given as parameter. The password will contain a mix of lower case letters,
# upper case letters, numbers and special characters.
function Get-RandomPassword {
    Param(
        [Parameter(Mandatory=$true)]
        [int]$Length
    )
    Begin{
        $Numbers = 1..9
        $LettersLower = 'abcdefghijklmnopqrstuvwxyz'.ToCharArray()
        $LettersUpper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray()
        $Special = '!@#$%^&*();.,\'.ToCharArray()
    
        $N_Count = [math]::Round($Length * .2)
        $L_Count = [math]::Round($Length * .2)
        $U_Count = [math]::Round($Length * .2)
        $S_Count = [math]::Round($Length * .2)
    }
    Process{
        $psswrd = $LettersLower | Get-Random -Count $L_Count
        $psswrd += $LettersUpper | Get-Random -Count $U_Count
        $psswrd += $Numbers | Get-Random -Count $N_Count
        $psswrd += $Special | Get-Random -Count $S_Count

        if($psswrd.length -lt $Length){
            $psswrd += $Special | Get-Random -Count ($Length - $passwd.length)
        }

        $psswrd = ($psswrd | Get-Random -Count $Length) -join ''
    }
    End{$psswrd}
}

Write-Host "Results will be written to $exportPath"

$export | ForEach-Object{
    $user = $_
    $name = $user.firstName
    $OU = $user.OU
    $samName = $user.userLogonName
    $exists = [bool] (Get-ADUser -Filter {SamAccountName -eq $name})
    
    if ($exists){
        Write-Host "user $name already exists"
        $user.initialPassword = 'N/A'
        $user.existsAlready = 'True'
    } else {
        $psswrd = Get-RandomPassword -Length 8
        $user.initialPassword = $psswrd
        $user.existsAlready = 'False'

        New-ADUser -AccountPassword $passwrd -Name $name -SamAccountName $samName -Path "OU=$OU,DC=blaze,DC=lab"
        Write-Host "creating user $name with password : $psswrd" -ForegroundColor Cyan
    }
}

$export | Export-Csv -Path $exportPath -NoTypeInformation