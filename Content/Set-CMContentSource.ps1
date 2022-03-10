<#
  Date:    29-Mar-2016
  Author:  Mark Goodman (Dell)
  Version: 1.0
  
  This script is provided "AS IS" with no warranties, confers no rights and 
  is not supported by the authors or Dell.
#>

<#
    .SYNOPSIS
    Lists packages whose source path does not start with the specified path.

    .DESCRIPTION
    This script lists packages whose source path does not start with the specified path.
    Specify the -Match parameter to list the packages whose source path starts with the specified path.

    .PARAMETER PackagePath
    Specifies the path or part of path for packages to search for. Any package whose source path does not start with this value will be listed.
	
	.PARAMETER SUDPackagePath
	Specifies the path or part of path for software update deployment packages to search for. Any software update deployment package whose source path does not start with this value will be listed.
	
    .PARAMETER DriverPath
    Specifies the path or part of path for drivers to search for. Any driver whose source path does not start with this value will be listed.

    .PARAMETER DriverPackagePath
    Specifies the path or part of path for driver packages to search for. Any driver package whose source path does not start with this value will be listed.

    .PARAMETER Match
    Specifing the Match parameter returns all packages that start with the specified path.

	.EXAMPLE
    Get-CMPackageSource.ps1 -PackagePath "\\Server\Packages" -SUDPackagePath "\\Server\SoftwareUpdates" -DriverPath "\\Server\Drivers" -DriverPackagePath "\\Server\DriverPackages"
	
	Description
	-----------
	
#>

<#  Parameters  #>
[cmdletbinding()]
param(
    [parameter(mandatory=$true,Position=0)][ValidateNotNullOrEmpty()][string]$Path,
    [parameter(mandatory=$true,Position=1)][ValidateNotNullOrEmpty()][String]$NewPath,
    [parameter(mandatory=$false)][switch]$Include = $false,
    [parameter(mandatory=$false)][String]$LogPath = "CMContentUpdate.log",
    [parameter(mandatory=$false,ParameterSetName="Limit")][switch]$Package = $false,
    [parameter(mandatory=$false,ParameterSetName="Limit")][switch]$SoftwareUpdateDeploymentPackage = $false,
	[parameter(mandatory=$false,ParameterSetName="Limit")][switch]$Driver = $false,
	[parameter(mandatory=$false,ParameterSetName="Limit")][switch]$DriverPackage = $false,
    [parameter(mandatory=$false,ParameterSetName="Limit")][switch]$BootImage = $false,
    [parameter(mandatory=$false,ParameterSetName="Limit")][switch]$OperatingSystemImage = $false
)

Process
{
    <# Script Variables #>
    #Requires -Version 4.0
    Set-StrictMode -Version Latest 
    $ScriptDir = split-path -path $MyInvocation.MyCommand.Path -parent
    $GetScriptFile = "$ScriptDir\Get-CMContentSource.ps1"

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
    Start-Transcript -Path "FileSystem::$ScriptDir\$LogPath"

    # Check for Configuration Manager module
    If ((Get-Module -Name ConfigurationManager) -ne $null) {
        # Check Get-CMContentSource.ps1 script is available
        # Eventually should make this a module
        If (Test-Path -Path $GetScriptFile)
        { 
	        if (($All) -Or ($Package))
            {
                & FileSystem::$GetScriptFile -Path $Path -Include -Package | % { Set-CMPackage -Id $_.PackageID -Path (Get-NewPath -SourcePath $_.PkgSourcePath -Path $Path -NewPath $NewPath) }
    	    }
	
	        if (($All) -Or ($SoftwareUpdateDeploymentPackage))
            {
                & FileSystem::$GetScriptFile -Path $Path -Include -SoftwareUpdateDeploymentPackage | % { Set-CMSoftwareUpdateDeploymentPackage -Id $_.PackageID -Path (Get-NewPath -SourcePath $_.PkgSourcePath -Path $Path -NewPath $NewPath) }
        	}
	
	        if (($All) -Or ($Driver)) 
            {
                & FileSystem::$GetScriptFile -Path $Path -Include -Driver | % { Set-CMDriver -Id $_.CI_ID -DriverSource (Get-NewPath -SourcePath $_.ContentSourcePath -Path $Path -NewPath $NewPath) }
	        }
	
	        if (($All) -Or ($DriverPackage))
            {
                & FileSystem::$GetScriptFile -Path $Path -Include -DriverPackage | % { Set-CMDriverPackage -Id $_.PackageID -DriverPackageSource (Get-NewPath -SourcePath $_.PkgSourcePath -Path $Path -NewPath $NewPath) }
	        }

	        if (($All) -Or ($BootImage))
            {
                # Boot Images needs work as there is more than just the path to consider
                #& FileSystem::$GetScriptFile -Path $Path -Include -BootImage | % { Set-CMBootImage -Id $_.PackageID -Path (Get-NewPath -SourcePath $_.PkgSourcePath -Path $Path -NewPath $NewPath) }
	        }

	        if (($All) -Or ($OperatingSystemImage))
            {
                # Operating System Images needs work
                #& FileSystem::$GetScriptFile -Path $Path -Include -OperatingSystemImage | % { Set-CMOperatingSystemImage -Id $_.PackageID -Path (Get-NewPath -SourcePath $_.PkgSourcePath -Path $Path -NewPath $NewPath) }
	        }
      }
        else
        {
            Write-Warning -Message "Get-CMContentSource.ps1 script not found!"
        }
    }
    else {
	    Write-Warning -Message "Configuration Manager module is not loaded. Please load and try again."
    }

    Stop-Transcript
}

<# Functions #>
Begin
{
    Function Get-NewPath()
    {
        <#  Parameters  #>
        [cmdletbinding()]
        param(
            [parameter(mandatory=$true,Position=0)][ValidateNotNullOrEmpty()][String]$SourcePath,
            [parameter(mandatory=$true,Position=1)][ValidateNotNullOrEmpty()][String]$Path,
            [parameter(mandatory=$true,Position=2)][ValidateNotNullOrEmpty()][String]$NewPath
        )

        <# Main Code Block #>
        $rePath = [regex]::Escape($Path)
        $replacePath = $SourcePath -ireplace "^$rePath", $NewPath
        Return $replacePath
    }
}