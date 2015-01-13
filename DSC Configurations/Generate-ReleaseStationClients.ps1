<#
.Synopsis
   This is used to allow for batch generating and regenerating DSC configurations. 
.DESCRIPTION
   This is a script that runs all of the stated configurations to create mof files in a batch to save on typing each command.
.EXAMPLE
   .\Generate-ReleaseStationClients.ps1
   Start-DscConfiguration .\ReleaseStationClients -Verbose -Wait
.LINK
    mailto:kingrolloinc@sbcglobal.net
#>
if((Test-Path ReleaseStationClients) -eq $true){
    "Deleting Old Configurations"
    Remove-Item .\ReleaseStationClients\ -Recurse -Force
}

.\ReleaseStationClients.ps1 -MachineName Arch-PC-610 -Configuration PrintRoom5
.\ReleaseStationClients.ps1 -MachineName Arch-PC-614 -Configuration PrintRoom4
.\ReleaseStationClients.ps1 -MachineName Arch-PC-623 -Configuration PlottingPit6
.\ReleaseStationClients.ps1 -MachineName Arch-PC-626 -Configuration PrintRoom6
.\ReleaseStationClients.ps1 -MachineName Arch-PC-629 -Configuration LaserSB
.\ReleaseStationClients.ps1 -MachineName Arch-PC-646 -Configuration PlottingPit5
.\ReleaseStationClients.ps1 -MachineName Arch-PC-656 -Configuration Secure3
.\ReleaseStationClients.ps1 -MachineName Arch-PC-667 -Configuration PlottingPit7
.\ReleaseStationClients.ps1 -MachineName Arch-PC-674 -Configuration PrintRoom7
.\ReleaseStationClients.ps1 -MachineName Arch-PC-691 -Configuration PlottingPit4