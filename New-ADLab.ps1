$domainName = "lab"
$topLevelDomain = "lcl"
$CEODepartment = "Administration"
$ManagersPerDepartment = 2
$EmployeesPerManager = 10
$departmentList = "Customer Service", "Sales", "Marketing", "Legal", "Help Desk", "Human Resources", "Accounting"

#Functions
Function New-FirstName 
{
   Return "Erich", "Domenic", "Wayne", "Darryl", "Luis", "Darell", "King", "Salvatore", "George", "Francis", "Sherwood", "Dino", "Patrick", "Burton", "Columbus", "Isaias", "Shad", "Todd", "Trent", "Garfield", "Frankie", "Lenny", "Scottie", "Romeo", "Jame", "Neville", "Terrance", "Clay", "Ulysses", "Gonzalo", "Fidel", "Virgil", "Bruno", "Rashad", "Archie", "Jeramy", "Cleo", "Yong", "Judson", "Earle", "Mack", "Tyrell", "Robbie", "Fermin", "Jamey", "Santos", "Pedro", "Albert", "Jerrold", "Arnulfo", "Ammie", "Susy", "Renay", "Terica", "Dalia", "Noemi", "Avelina", "Janelle", "Le", "Marquitta", "Kathe", "Lavada", "Lorine", "Delila", "Olga", "Lecia", "Dovie", "Theola", "Deann", "Donetta", "Elicia", "Vella", "Valery", "Verlene", "Cierra", "Kizzy", "Kerri", "Laurine", "Junie", "Lavonda", "Chieko", "Carissa", "Stefania", "Gina", "Neda", "Sunny", "Corazon", "Marylouise", "Anitra", "Elfriede", "Lillie", "Catalina", "Caron", "Pinkie", "Shanel", "Rachel", "Fay", "Matilde", "Renae", "Tish" | Get-Random
}
Function New-LastName 
{
   return "Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor", "Anderson", "Thomas", "Jackson", "White", "Harris", "Martin", "Thompson", "Garcia", "Martinez", "Robinson", "Clark", "Rodriguez", "Lewis", "Lee", "Walker", "Hall", "Allen", "Young", "Hernandez", "King", "Wright", "Lopez", "Hill", "Scott", "Green", "Adams", "Baker", "Gonzalez", "Nelson", "Carter", "Mitchell", "Perez", "Roberts", "Turner", "Phillips", "Campbell", "Parker", "Evans", "Edwards", "Collins", "Stewart", "Sanchez", "Morris", "Rogers", "Reed", "Cook", "Morgan", "Bell", "Murphy", "Bailey", "Rivera", "Cooper", "Richardson", "Cox", "Howard", "Ward", "Torres", "Peterson", "Gray", "Ramirez", "James", "Watson", "Brooks", "Kelly", "Sanders", "Price", "Bennett", "Wood", "Barnes", "Ross", "Henderson", "Coleman", "Jenkins", "Perry", "Powell", "Long", "Patterson", "Hughes", "Flores", "Washington", "Butler", "Simmons", "Foster", "Gonzales", "Bryant", "Alexander", "Russell", "Griffin", "Diaz", "Hayes" | Get-Random
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

function New-Employee
{
   param (
      [string]$Path,
      [string]$Department
  )

   $EmployeeData = New-Object psobject -Property @{
      Password = New-RandomPassword
      Phone = New-FakePhoneNumber
      EmployeeNumber = New-EmployeeNumber 
      GivenName = New-FirstName
      Surname = New-LastName
   }

   [Array]$userExist = Get-ADUser -Filter "Surname -like '$($EmployeeData.surName)*'" -Properties GivenName,Surname | Where-Object {$_.GivenName -eq $EmployeeData.GivenName}
   $userExist += try{Get-ADUser -Identity ("$($EmployeeData.GivenName.Substring(0)[0])" + "$($EmployeeData.surName)")}catch{}
   if($userExist.Surname.Count -gt 0)
   {
      $lastName = $userExist | Sort-Object -Property surName | Select-Object -Property surName -Last 1
      [Int]$int = $lastName.surName.Substring(0) -replace "[a-zA-Z]", ""
      $EmployeeData.Surname = ($EmployeeData.Surname + ($int = $int + 1))
   }
   [String]$SamAccountName = "$($EmployeeData.GivenName.Substring(0)[0])" + "$($EmployeeData.surName)"
   return New-ADUser -Name ($EmployeeData.GivenName+" "+$EmployeeData.surName)-GivenName $EmployeeData.GivenName -Surname $EmployeeData.surName -AccountPassword (ConvertTo-SecureString $EmployeeData.password -AsPlainText -Force) -OfficePhone $phone -Enabled $true -Department $Department -SamAccountName $SamAccountName -EmployeeNumber $EmployeeNumber -DisplayName ($EmployeeData.GivenName+" "+$EmployeeData.surName) -EmailAddress ($EmployeeData.GivenName+"."+$EmployeeData.surName+"@"+$domainName+".$topLevelDomai") -Path $Path -PassThru
}

#create orgranization unit to store users
$ouPath = "DC=$domainName,DC=$topLevelDomain"
$ouName = "UserAccounts"
$ouUserPath = "$("OU="+$ouName+","+$ouPath)"
New-ADOrganizationalUnit -Name "$ouName" -Path "$ouPath" -ProtectedFromAccidentalDeletion $False

#creating CEO
New-ADOrganizationalUnit -Name "$CEODepartment" -Path "$ouUserPath" -ProtectedFromAccidentalDeletion $False
$CEO = New-Employee -Department "$CEODepartment" -Path $("OU=$CEODepartment," + $ouUserPath)
Write-Output "Created CEO $($CEO.name)"

Foreach ($deparment in $departmentList)
{
   #Creating VPs
   $VP = New-Employee -Department "$CEODepartment" -Path $("OU=$CEODepartment," + $ouUserPath)
   Write-Output "Created VP $($VP.name)"
   Set-ADUser -Identity $VP -Manager $CEO

   #Creating Department Oraganization Unit
   New-ADOrganizationalUnit -Name "$deparment" -Path "$ouUserPath" -ProtectedFromAccidentalDeletion $False
   
   #Creating Managers
   [Int]$ManCount = 0
   While ([Int]$ManCount -lt $ManagersPerDepartment)
   {
      $Manager = New-Employee -Department $deparment -Path $("OU=$deparment," + $ouUserPath)
      Set-ADUser -Identity $Manager -Manager $VP
      Write-Output "Created Manager $($Manager.name)"

      #Creating Employees
      [Int]$EmpCount = 0
      While([Int]$EmpCount -lt $EmployeesPerManager)
      {
         $Employee = New-Employee -Department $deparment -Path $("OU=$deparment," + $ouUserPath)
         Set-ADUser -Identity $Employee -Manager $Manager
         Write-Output "Created Employee $($Employee.name)"
         $EmpCount++
      }
      $ManCount++
   }
}
