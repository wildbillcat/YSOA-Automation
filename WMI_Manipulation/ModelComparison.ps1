<#
.Synopsis
   This fetches the Computer Model from WMI to then be used for comparison
.DESCRIPTION
   This is a script that finds the local computer's 
.EXAMPLE
   Set-ComputerOU.ps1 -ComputerName PC1,PC2,PC3 -OUPath "OU=6th Floor Lab,OU=Teaching Labs,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
.LINK
    mailto:patrick.mcmorran@yale.edu
#>
$ComputerModel = Get-WmiObject -Class Win32_ComputerSystem | select model

if($ComputerModel -eq "Precision T3610"){

}

if($ComputerModel -eq "Precision T3600"){

}

if($ComputerModel -eq "Precision WorkStation T3500"){

}