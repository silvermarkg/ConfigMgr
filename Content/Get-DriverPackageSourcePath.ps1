[cmdletbinding()]
param(
    [parameter(mandatory=$true)][ValidateNotNullOrEmpty()]$OldShare,
    [parameter(mandatory=$true)][ValidateNotNullOrEmpty()]$NewShare,
    [parameter(mandatory=$false)][ValidateNotNullOrEmpty()]$DistributionPointName = "",
    [parameter(mandatory=$false)][switch]$Check = $false
)

#Auto Escape string incase it includes Regualar Expression characters
$reOldShare = [regex]::escape($OldShare)

Get-CMDriverPackage -name * | where-object {
    $_.PkgSourcePath -like "$OldShare*"
} | Foreach-object {
    # Get new package source path
    $newPkgSourcePath = $_.PkgSourcePath -ireplace "^$reOldShare", $NewShare
    " "
    "Deployment Package: {0}" -f $_.Name
    "  Old Path: {0}" -f $_.PkgSourcePath
    "  New Path: {0}" -f $newPkgSourcePath

    #Check new package source folder exists
    if (test-path -path "FileSystem::$newPkgSourcePath") {
        "  New source path exists"

        if (!($Check)) {
            <#
            "  Updating deployment package source path"
            Set-CMSoftwareUpdateDeploymentPackage -Id $_.PackageID -Path $newPkgSourcePath

            if ($DistributionPointName -ne "") {
                #Distribute content
                "  Distributing content to {0}" -f $DistributionPointName
                Start-CMContentDistribution -DeploymentPackageId $_.PackageID -DistributionPointName $DistributionPointName
            }
            #>
        }
    }
    else {
        write-host "  New driver package source path does not exist!" -ForegroundColor Red
    }
}
