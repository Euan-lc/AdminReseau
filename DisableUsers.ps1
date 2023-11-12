param($path,$delimiter=';')

$csv = Import-Csv -Delimiter $delimiter -Path $path

$csv | ForEach-Object {
    $user = $_
    $sam = $user.sam

    Disable-ADAccount -Identity $sam
}