param($path,$delimiter=';')
# Charger le contenu du CSV
$csvData = Import-Csv -Delimiter $delimiter -Path $path

# Parcourir chaque ligne du CSV
foreach ($entry in $csvData) {
    # Récupérer les informations nécessaires
    $oldUsername = $entry.Username
    $newLastName = $entry.NouveauNom
    $newFirstName = $entry.NouveauPrenom
    $newOU = $entry.NouveauOU
    $newSecurityGroup = $entry.NouveauGroupeSecurite

    # Rechercher l'utilisateur dans Active Directory
    $user = Get-ADUser -Filter {SamAccountName -eq $oldUsername}

    # Vérifier si l'utilisateur a été trouvé
    if ($user) {
        # Mettre à jour les informations de l'utilisateur
        Set-ADUser -Identity $oldUsername -Surname $newLastName -GivenName $newFirstName 
        
        # Déplacer l'utilisateur vers l'unité organisationnelle spécifiée
        if ($newOU) {
            Move-ADObject -Identity $user.DistinguishedName -TargetPath $newOU
        }

        # Ajouter l'utilisateur au groupe de sécurité spécifié
        if ($newSecurityGroup) {
            Add-ADGroupMember -Identity $newSecurityGroup -Members $user
        }

        Write-Host "Les informations de $oldUsername ont été mises à jour."
    } else {
        Write-Host "Utilisateur $oldUsername non trouvé dans Active Directory."
    }
}

Write-Host "Modification des utilisateurs terminée."
