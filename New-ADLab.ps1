$companyName = "lab"
$CEODepartment = "Administration"
$ManagersPerDepartment = 2
$EmployeesPerManager = 10
$departmentList = "Customer Service", "Sales", "Marketing", "Legal", "Help Desk", "Human Resources", "Accounting"

#Functions
Function New-FirstName 
{
   $firstNames = "Erich", "Domenic", "Wayne", "Darryl", "Luis", "Darell", "King", "Salvatore", "George", "Francis", "Sherwood", "Dino", "Patrick", "Burton", "Columbus", "Isaias", "Shad", "Todd", "Trent", "Garfield", "Frankie", "Lenny", "Scottie", "Romeo", "Jame", "Neville", "Terrance", "Clay", "Ulysses", "Gonzalo", "Fidel", "Virgil", "Bruno", "Rashad", "Archie", "Jeramy", "Cleo", "Yong", "Judson", "Earle", "Mack", "Tyrell", "Robbie", "Fermin", "Jamey", "Santos", "Pedro", "Albert", "Jerrold", "Arnulfo", "Ammie", "Susy", "Renay", "Terica", "Dalia", "Noemi", "Avelina", "Janelle", "Le", "Marquitta", "Kathe", "Lavada", "Lorine", "Delila", "Olga", "Lecia", "Dovie", "Theola", "Deann", "Donetta", "Elicia", "Vella", "Valery", "Verlene", "Cierra", "Kizzy", "Kerri", "Laurine", "Junie", "Lavonda", "Chieko", "Carissa", "Stefania", "Gina", "Neda", "Sunny", "Corazon", "Marylouise", "Anitra", "Elfriede", "Lillie", "Catalina", "Caron", "Pinkie", "Shanel", "Rachel", "Fay", "Matilde", "Renae", "Tish"
   $return = $firstNames | Get-Random
   Return $return
}
Function New-LastName 
{
   $lastNames = "Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor", "Anderson", "Thomas", "Jackson", "White", "Harris", "Martin", "Thompson", "Garcia", "Martinez", "Robinson", "Clark", "Rodriguez", "Lewis", "Lee", "Walker", "Hall", "Allen", "Young", "Hernandez", "King", "Wright", "Lopez", "Hill", "Scott", "Green", "Adams", "Baker", "Gonzalez", "Nelson", "Carter", "Mitchell", "Perez", "Roberts", "Turner", "Phillips", "Campbell", "Parker", "Evans", "Edwards", "Collins", "Stewart", "Sanchez", "Morris", "Rogers", "Reed", "Cook", "Morgan", "Bell", "Murphy", "Bailey", "Rivera", "Cooper", "Richardson", "Cox", "Howard", "Ward", "Torres", "Peterson", "Gray", "Ramirez", "James", "Watson", "Brooks", "Kelly", "Sanders", "Price", "Bennett", "Wood", "Barnes", "Ross", "Henderson", "Coleman", "Jenkins", "Perry", "Powell", "Long", "Patterson", "Hughes", "Flores", "Washington", "Butler", "Simmons", "Foster", "Gonzales", "Bryant", "Alexander", "Russell", "Griffin", "Diaz", "Hayes"
   $return = $lastNames | Get-Random
   return $return
}
Function New-RandomPassword 
{
   $Length = 14
   While($PasswordString.Length -lt $Length)
   {
       if ($PasswordString.Length -lt $Length) {$PasswordString += -join ((97..122) | Get-Random -Count "1" | % {[char]$_}) } #Lower Case
       if ($PasswordString.Length -lt $Length) {$PasswordString += -join ((65..90) | Get-Random -Count "1" | % {[char]$_}) } #Upper Case
       if ($PasswordString.Length -lt $Length) {$PasswordString += -join ((49..57) | Get-Random -Count "1" | % {[char]$_}) } #Numbers
       if ($PasswordString.Length -lt $Length) {$PasswordString += -join ((35..38) + (40..43) + (58..64) | Get-Random -Count "1" | % {[char]$_}) } #Special Characters
   }
   [string]$TempPassword = ($PasswordString -split '' | Sort-Object {Get-Random}) -join ''
   return $TempPassword 
}
Function New-FakePhoneNumber 
{
   $areaCode = "772"
   $prefix = "834", "306"
   $numberList = "1","2","3","4","5","6","7","8","9","0"
   
   [string]$PhoneNumber = ($areaCode | Get-Random) + ($prefix | Get-Random)
   While($PhoneNumber.Length -lt 10){$PhoneNumber += ($numberList | Get-Random)}
   return $PhoneNumber 
}
Function New-EmployeeNumber 
{
   $numberList = "1","2","3","4","5","6","7","8","9","0"
   [string]$number = ($numberList | Get-Random)
   While($number.Length -lt 8){$number += ($numberList | Get-Random)}
   return $number 
}

function New-RandomUser
{
   Param([String]$Department,
       [string]$ouLocation
   )    

   $allADUsers = Get-ADUser -Filter * -Properties SamAccountName, OfficePhone, lastNames
   $password = New-RandomPassword

   $phone = New-FakePhoneNumber
   $EmployeeNumber
   $GivenName = 
   $surName = 

   $SamAccountName = 











   $newUser = New-ADUser -Name ($GivenName+" "+$surName)-GivenName $GivenName -Surname $surName -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -OfficePhone $phone -Enabled $true -Department $Department -SamAccountName $SamAccountName -EmployeeNumber $EmployeeNumber -DisplayName ($GivenName+" "+$surName) -EmailAddress ($GivenName+"."+$surName+"@"+$companyName+".com") -Path "$ouLocation" -PassThru
   return $newUser
}

#create orgranization unit to store users
$ouPath = "DC=$companyName,DC=lcl"
$ouName = "UserAccounts"
$ouUserPath = "$("OU="+$ouName+","+$ouPath)"
New-ADOrganizationalUnit -Name "$ouName" -Path "$ouPath" -ProtectedFromAccidentalDeletion $False

#creating organization users
$CEO = New-RandomUser -Department $CEODepartment -ouLocation $ouUserPath
Write-Output "Created CEO $($CEO.name)"
Foreach ($deparment in $departmentList)
{
   $VP = New-RandomUser -Department $deparment -ouLocation $ouUserPath
   Write-Output "Created VP $($VP.name)"
   Set-ADUser -Identity $VP -Manager $CEO

   $Managers = @()
   While ($Managers.count -lt $ManagersPerDepartment)
   {
       $Manager = New-RandomUser -Department $deparment -ouLocation $ouUserPath
       Write-Output "Created Manager $($Manager.name)"
       Set-ADUser -Identity $Manager -Manager $VP

       $Employees = @()
       While($Employees.count -lt $EmployeesPerManager)
       {
           
           $Employee = New-RandomUser -Department $deparment -ouLocation $ouUserPath
           Write-Output "Created Employee $($Employee.name)"
           Set-ADUser -Identity $Employee -Manager $Manager

           $Employees += $Employee
       }
       $Managers += $Manager
   }
}