<#
.Synopsis
   This is used to allow for batch generating and regenerating DSC configurations. 
.DESCRIPTION
   This is a script that runs all of the stated configurations to create mof files in a batch to save on typing each command.
.EXAMPLE
   .\Generate-SignageClientsClients.ps1
   Start-DscConfiguration .\SignageClients -Verbose -Wait
.LINK
    mailto:patrick.mcmorran@yale.edu
#>
if((Test-Path ReleaseStationClients) -eq $true){
    "Deleting Old Configurations"
    Remove-Item .\SignageClients\ -Recurse -Force
}

$SignageMachines = Get-ADComputer -SearchBase 'OU=Signage,OU=Infrastructure,OU=Architecture,OU=Architecture,DC=yu,DC=yale,DC=edu' -Filter '*' | select -ExpandProperty name
ForEach($Machine in $SignageMachines){
    .\SignageClients.ps1 -MachineName $Machine
}