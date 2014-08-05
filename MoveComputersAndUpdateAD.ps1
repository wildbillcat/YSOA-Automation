<#
.Synopsis
   This moves a computer object in the active directory, then GPUpdating it.
.DESCRIPTION
   This is a script that finds the specified computers in the AD the puts them into the desired active directory OU.
   It then starts a job to GPUpdate each PC.
.EXAMPLE
    MoveComputersAndUpdateAD.ps1 -ComputerName ((Get-Content .\PCsInQuestion.txt)) -DestinationOU "OU=SOA 6th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
.LINK
    mailto:patrick.mcmorran@yale.edu
#>
Param(
    [Parameter(Mandatory=$true)]
    [string[]]$ComputerName,
    [Parameter(Mandatory=$true)]
    [string]$DestinationOU    
)

foreach($Computer in $computerName){
    Move-ADObject -Identity (Get-ADComputer $Computer).objectguid -TargetPath $DestinationOU
    
    Invoke-Command -AsJob -ComputerName $Computer {
        gpupdate /force
        shutdown -t 0 -r
    }         
}