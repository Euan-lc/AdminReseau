param($path, $delimiter=';')

# Load CSV content
$csvData = Import-Csv -Delimiter $delimiter -Path $path

# Browse each line of the CSV
foreach ($entry in $csvData) {
    # Retrieve the necessary information
    $username = $entry.Username

    # Find user in Active Directory
    $user = Get-ADUser -Filter {SamAccountName -eq $username} -Properties BadPwdCount,LockedOut

    # Check if the user has been found
    if ($user) {
        # Check if the user account is locked
        if ($user.LockedOut -and $user.BadPwdCount -ge 3) {
            # Unlock user account
            Unlock-ADAccount -Identity $username
            Write-Host "User account $username has been unlocked."
        } else {
            Write-Host "User account $username is not locked or has not exceeded the allowed number of failed login attempts."
        }
    } else {
        Write-Host "User $username not found in Active Directory."
    }
}

Write-Host "User account unlocking complete."

