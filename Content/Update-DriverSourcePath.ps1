<#
  Date:    01-Jul-2015
  Author:  Mark Goodman (Dell)
  Version: 1.0
  
  This script is provided "AS IS" with no warranties, confers no rights and 
  is not supported by the authors or Dell.
#>

<#
    .SYNOPSIS
    Update the source path of drivers.

    .DESCRIPTION
    This script updates the source path of any driver whose source path starts with the value specified in the Path parameter.
	This script is intended for use as part of a migration.

    .PARAMETER Path
    Specifies the path or part of path to search for. Any driver whose source path starts with this value will be updated.
	
	.PARAMETER NewPath
	Specifies the new path to replace the Path value.
	
    .EXAMPLE
    Update-DriverSourcePath.ps1 -Path "C:\Drivers" -NewPath "\\Server\Drivers"
	
	Description
	-----------
	This example will search for any drivers whose source path starts with "C:\Drivers" and replace this value with "\\Server\Drivers"
	e.g. C:\Drivers\Windows7x68 --> \\Server\Drivers\Windows7x86
#>

<#  Parameters  #>
[cmdletbinding()]
param(
    [parameter(mandatory=$true)][ValidateNotNullOrEmpty()]$Path,
    [parameter(mandatory=$true)][ValidateNotNullOrEmpty()]$NewPath
)

# Check for Configuration Manager module
If ((Get-Module -Name ConfigurationManager) -ne $null) {
	#Auto Escape string incase it includes Regualar Expression characters
	$rePath = [regex]::escape($Path)
	$itemNum = 0

	$drivers = Get-CMDriver -Name * | Where-Object { $_.ContentSourcePath -like "$Path*" }
	$drivers | Foreach-Object {
		$itemNum++
		$Activity = ("Driver: {0} - {1}" -f $_.CI_ID,$_.LocalizedDisplayName)

		# Get new package source path
		$newPkgSourcePath = $_.ContentSourcePath -ireplace "^$rePath", $NewPath

		#Check new package source folder exists
		write-progress -Activity $Activity -status ("Checking for new source path '{0}'" -f $newPkgSourcePath) -PercentComplete ($itemNum / $drivers.Count*100)
		if (test-path -path "FileSystem::$newPkgSourcePath") {
			Write-Progress -Activity $Activity -Status "Updating driver source path" -PercentComplete ($itemNum / $drivers.Count*100)
			Set-CMDriver -Id $_.CI_ID -DriverSource $newPkgSourcePath
			Write-Host -Object ("{0} updated: {1}" -f $_.LocalizedDisplayName, $newPkgSourcePath) -ForegroundColor Green
		}
		else {
			Write-Host -Object ("{0} error: New path not found ({1})" -f $_.LocalizedDisplayName, $newPkgSourcePath) -ForegroundColor Red
		}
	 }
}
else {
	Write-Host -Object "Configuration Manager module is not loaded. Please load and try again." -ForegroundColor Red
}