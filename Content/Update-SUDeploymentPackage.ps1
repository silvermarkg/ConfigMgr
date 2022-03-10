<#
  Date:    01-Jul-2015
  Author:  Mark Goodman (Dell)
  Version: 1.0
  
  This script is provided "AS IS" with no warranties, confers no rights and 
  is not supported by the authors or Dell.
#>

<#
    .SYNOPSIS
    Update the source path of software update deployment packages.

    .DESCRIPTION
    This script updates the source path of any software update deployment package whose source path starts with the value specified in the Path parameter.
	This script is intended for use as part of a migration.

    .PARAMETER Path
    Specifies the path or part of path to search for. Any software update deployment package whose source path starts with this value will be updated.
	
	.PARAMETER NewPath
	Specifies the new path to replace the Path value.
	
    .EXAMPLE
    Update-SUDeploymentPackage.ps1 -Path "C:\SoftwareUpdates" -NewPath "\\Server\SoftwareUpdates"
	
	Description
	-----------
	This example will search for any software update deployment packages whose source path starts with "C:\SoftwareUpdates" and replace this value with "\\Server\SoftwareUpdates"
	e.g. C:\SoftwareUpdates\2015-06 (June) --> \\Server\SoftwareUpdates\2015-06 (June)
#>

<#  Parameters  #>
[cmdletbinding()]
param(
    [parameter(mandatory=$true)][ValidateNotNullOrEmpty()]$Path,
    [parameter(mandatory=$true)][ValidateNotNullOrEmpty()]$NewPath
)

# Check for Configuration Manager module
If ((Get-Module -Name ConfigurationManager) -ne $null) {
	#Auto Escape string in case it includes Regular Expression characters
	$rePath = [regex]::escape($Path)
	$itemNum = 0

	$packages = Get-CMSoftwareUpdateDeploymentPackage -Name * | Where-Object {	$_.PkgSourcePath -like "$Path*"	}
	$packages | Foreach-Object {
		$itemNum++
		$Activity = ("Package: {0} - {1}" -f $_.PackageID,$_.Name)

		# Get new package source path
		$newPkgSourcePath = $_.PkgSourcePath -ireplace "^$rePath", $NewPath

		#Check new package source folder exists
		write-progress -Activity $Activity -status ("Checking for new source path '{0}'" -f $newPkgSourcePath) -PercentComplete ($itemNum / $packages.Count*100)
		if (test-path -path "FileSystem::$newPkgSourcePath") {
			Write-Progress -Activity $Activity -Status "Updating driver source path" -PercentComplete ($itemNum / $packages.Count*100)
			Set-CMSoftwareUpdateDeploymentPackage -Id $_.PackageID -Path $newPkgSourcePath
			Write-Host -Object ("{0} updated: {1}" -f $_.Name, $newPkgSourcePath) -ForegroundColor Green
		}
		else {
			Write-Host -Object ("{0} error: New path not found ({1})" -f $_.Name, $newPkgSourcePath) -ForegroundColor Red
		}
	}
}
else {
	Write-Host -Object "Configuration Manager module is not loaded. Please load and try again." -ForegroundColor Red
}