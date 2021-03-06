﻿<#
.Synopsis
   This moves a computer object in the active directory
.DESCRIPTION
   This is a script that finds the specified computers in the AD the puts them into the desired active directory OU.
   After changing the Computer's OU you should force a GPUpdate to ensure group policy is applied correctly.
.EXAMPLE
   Set-ComputerOU.ps1 -ComputerName PC1,PC2,PC3 -OUPath "OU=6th Floor Lab,OU=Teaching Labs,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
.LINK
    mailto:kingrolloinc@sbcglobal.net
#>
Param(
    [Parameter(Mandatory=$true)]
    [string[]]$ComputerName,
    [Parameter(Mandatory=$true)]
    [string]$OUPath    
)


foreach($Computer in $ComputerName){
        Move-ADObject -Identity (Get-ADComputer $Computer).objectguid -TargetPath $OUPath
}