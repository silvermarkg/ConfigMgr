[CmdletBinding()]
param (
    [Parameter(Mandatory=$false,Position=0)]
    [ValidateNotNullOrEmpty()]
    [String]$Name = "*"
)

# Initialise variables
$DTList = @()

# Get application
$Apps = Get-CMApplication -Name $Name
$AppsCount = ($Apps | Measure-Object).Count
$Counter = 0
foreach ($App in $Apps) {
	$Counter++
	Write-Progress -Activity "Reading application content paths" -CurrentOperation "Processing $($App.LocalizedDisplayName)" -PercentComplete (($Counter / $AppsCount) * 100)
	
	# Convert to application SDK object
	$AppSDK = ConvertTo-CMApplication -InputObject $App

	# Process each DT
	foreach ($DT in $AppSDK.DeploymentTypes) {
		# Update content paths
		foreach ($Content in $DT.Installer.Contents) {
			if ($DT.Installer.InstallContent.Id -eq $Content.Id) {
				$ContentType = "Install"
			}
			elseif ($DT.Installer.UninstallContent.Id -eq $Content.Id) {
				$ContentType = "Uninstall"
			}
			else {
				$ContentType = "Unknown"
			}

			$DTList += [PSCustomObject]@{
				Application = $App.LocalizedDisplayName
				DeploymentType = $DT.Title
				ContentType = $ContentType
				CurrentPath = $Content.Location
			}
		}
	}
}

Write-Output $DTList
