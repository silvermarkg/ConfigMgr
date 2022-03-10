<#
  Date:    29-Mar-2016
  Author:  Mark Goodman (Dell)
  Version: 2.0
  
  This script is provided "AS IS" with no warranties, confers no rights and 
  is not supported by the authors or Dell.
#>

<#
    .SYNOPSIS
    Lists content whose source path does or does not start with the specified path.

    .DESCRIPTION
    This script lists content whose source path does not start with the specified path.
    by default the script excludes content that matches the path prefix. Use the -Include parameter to include content that matches the path prefix.
    The following content is searched:
    - Packages
    - Software Update Deployment Packages
    - Drivers
    - Driver Packages
    - Boot Images
    - Operating System Images
    
    .PARAMETER Path
    Specifies the path to match. This can be a full path or the start or a path.

    .PARAMETER Include
    Includes the content whose source path starts with the path specified. by default only content that does not match is returned.

    .PARAMETER Package
    Idicates to only search and return Packages.
	
	.PARAMETER SoftwareUpdateDeploymentPackage
	Indicates to only search and return Software Update Deployment Packages.
	
    .PARAMETER Driver
    Indicates to only search and return Drivers.

    .PARAMETER DriverPackage
    Indicates to only search and return Driver Packages.

    .PARAMETER BootImage
    Indicates to only search and return Boot Images.

    .PARAMETER OperatingSystemImages
    Indicates to only search and return Operating System Images.

	.EXAMPLE
    Get-CMContentSource.ps1 -Path "\\Server\Packages"
    	
	Description
	-----------
	Gets all content whose source path does not start with \\Server\Packages

	.EXAMPLE
    Get-CMContentSource.ps1 -Path "\\Server\Packages" -Include -Packages
    	
	Description
	-----------
	Gets all packages content whose source path starts with \\Server\Packages

	.EXAMPLE
    Get-CMContentSource.ps1 -Path "\\Server\Packages" -Driver -DriverPackage
    	
	Description
	-----------
	Gets all Drivers and Driver Packages content whose source path does not start with \\Server\Packages

#>

<#  Parameters  #>
[cmdletbinding()]
param(
    [parameter(mandatory=$true,Position=0)][ValidateNotNullOrEmpty()][string]$Path,
    [parameter(mandatory=$false)][switch]$Include = $false,
    [parameter(mandatory=$false,ParameterSetName="Limit")][switch]$Package = $false,
    [parameter(mandatory=$false,ParameterSetName="Limit")][switch]$SoftwareUpdateDeploymentPackage = $false,
	[parameter(mandatory=$false,ParameterSetName="Limit")][switch]$Driver = $false,
	[parameter(mandatory=$false,ParameterSetName="Limit")][switch]$DriverPackage = $false,
    [parameter(mandatory=$false,ParameterSetName="Limit")][switch]$BootImage = $false,
    [parameter(mandatory=$false,ParameterSetName="Limit")][switch]$OperatingSystemImage = $false
)

<# Script Variables #>
#Requires -Version 4.0
Set-StrictMode -Version Latest

If ($PSCmdlet.ParameterSetName -eq "Limit")
{
    $All = $false
}
Else
{
    $All = $true
}

If ($Include)
{
    $PackageFilter = @{"like"=$true}
}
Else
{
    $PackageFilter = @{"notlike"=$true}
}


<# Main Code Block #>

# Check for Configuration Manager module
If ((Get-Module -Name ConfigurationManager) -ne $null) {
	if (($All) -Or ($Package))
    {
		Write-Verbose -Message "Packages"
		Get-CMPackage | Where-Object -Property PkgSourcePath -Value "$Path*" @PackageFilter | Select-Object -Property Name,PackageID,PackageType,PkgSourcePath
	}
	
	if (($All) -Or ($SoftwareUpdateDeploymentPackage))
    {
		Write-Verbose -Message "Software Update Deployment Packages"
		Get-CMSoftwareUpdateDeploymentPackage | Where-Object -Property PkgSourcePath -Value "$Path*" @PackageFilter | Select-Object -Property Name,PackageID,PackageType,PkgSourcePath
	}
	
	if (($All) -Or ($Driver)) 
    {
		Write-Verbose -Message "Drivers"
		Get-CMDriver | Where-Object -Property ContentSourcePath -Value "$Path*" @PackageFilter | Select-Object -Property LocalizedDisplayName,CI_ID,ContentSourcePath
	}
	
	if (($All) -Or ($DriverPackage))
    {
		Write-Verbose -Message "Driver Packages"
		Get-CMDriverPackage | Where-Object -Property PkgSourcePath -Value "$Path*" @PackageFilter | Select-Object -Property Name,PackageID,PackageType,PkgSourcePath
	}

	if (($All) -Or ($BootImage))
    {
		Write-Verbose -Message "Boot Images"
		Get-CMBootImage | Where-Object -Property PkgSourcePath -Value "$Path*" @PackageFilter | Select-Object -Property Name,PackageID,PackageType,PkgSourcePath
	}

	if (($All) -Or ($OperatingSystemImage))
    {
		Write-Verbose -Message "Operating System Images"
		Get-CMOperatingSystemImage | Where-Object -Property PkgSourcePath -Value "$Path*" @PackageFilter | Select-Object -Property Name,PackageID,PackageType,PkgSourcePath
	}

    if (($All) -Or ($Applications))
    {
        Get-CMDeploymentType | % {
            $AppMgmt = ([xml]$_.SDMPackageXML).AppMgmtDigest
            $AppName = $AppMgmt.Application.DisplayInfo.FirstChild.Title
            $AppMgmt.DeploymentType | % {
                $DTName = $_.Title.innerText
                $DTPath = $_.Installer.Contents.Content.Location
            }
        }
    }
}
else {
	Write-Host -Object "Configuration Manager module is not loaded. Please load and try again." -ForegroundColor Red
}