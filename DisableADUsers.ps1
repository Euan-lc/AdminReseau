# This script disables active directory users based on the contents of a csv file with the structure shown on the next two lines.
# samAccountName
# Euan

# It's parameters are the delimiter of the csv file (the default is ;) the path of the csv file with the users to be disabled 

param($path,$delimiter=';')

$csv = Import-Csv -Delimiter $delimiter -Path $path

$csv | ForEach-Object {
    $row = $_
    $sam = $row.sam
    $exists = [bool] (Get-ADUser -Filter {SamAccountName -eq $sam})
    if($exists){
        $user = Get-ADUser -Filter {SamAccountName -eq $sam}
        if(($user | select Enabled)){
            Disable-ADAccount -Identity $sam
            Write-Host "User $sam has been disabled" -ForegroundColor Green
        } else{
            Write-Host "User $sam is already disabled" -ForegroundColor Red
        }
    } else {
        Write-Host "User $sam does not exist" -ForegroundColor Red
    }
    Disable-ADAccount -Identity $sam
}
