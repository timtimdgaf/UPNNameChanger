#------warning------#

Write-Warning "This script will add a new UPN and change all users to that UPN." -WarningAction Inquire

#-----input------#

$oldUpnSuffix = (Get-WmiObject Win32_ComputerSystem).Domain
Write-Host "$oldUpnSuffix"

$newUpnSuffix = Read-Host -Prompt 'Please enter new UserPrincipalName: (ie: contoso.com)'

#------output------#

Write-Host "Adding new UPN"
Get-ADForest | Set-ADForest -UPNSuffixes @{ add = $newUpnSuffix } -ErrorAction Stop

  Write-Host "Filtering all users"
  $userObjects = Get-ADUser -Filter "UserPrincipalName -like '*$oldUpnSuffix'" -Properties userPrincipalName -ResultSetSize $null -ErrorAction Stop
  Write-Host "Changing UPN for all users"
  foreach ($userObject in $userObjects)
  {
      $newUpn = $userObject.UserPrincipalName.Replace($oldUpnSuffix, $newUpnSuffix)
      Write-Host ("Updating upn for user {0} from {1} to {2}" -f $userObject.SamAccountName, $userObject.UserPrincipalName, $newUpn)
      Set-ADUser -Identity $userObject -UserPrincipalName $newUpn
  }
#-----------------#

