# Deploy-OrganizationUsers

This Powershell script will deploy an organization that will be composed of a CEO, VPs, Managers and Employees.


The script will also create an Organization unit called UserAccounts. The script will also create an Organization unit for each department and place the Departmet managers and employees with in that organization unit.

CEO and VPs will be placed in the Administration OU.

When a user is created the script will also do the following:
* First name and Last name are randomly selected
* Add random employee number
* Add random Phone number based on three area codes
* Link Employee to Managers, Managers to VPs and VPs to CEO
* Users will also have a random 14 chanracter password assiged to them
* Add the department name to the department field in AD

<p align="center">
  <img src="images/AD Structure.png">
</p>

Make sure you update the variables $domainName and $topLevelDomain to match your domain name and top-level domain.

Hope you enjoy and that it saves you time
