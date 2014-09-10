<#
.Synopsis
   This fetches the Computer Serial from WMI, and MAC to then be used for Label Making
.DESCRIPTION
   This is a script that finds the Service Tag and Mac Address for the computers specified, which can later be used for Labels.
.EXAMPLE
   Set-ComputerOU.ps1 -ComputerName PC1,PC2,PC3 -OUPath "OU=6th Floor Lab,OU=Teaching Labs,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
.LINK
    mailto:patrick.mcmorran@yale.edu
#>
Param(
    [Parameter(Mandatory=$true)]
    [string[]]$ComputerName
)

foreach($PC in $ComputerName) { 
if (Test-Connection -ComputerName $PC -Quiet) {
        $ServiceTag = Invoke-Command -ComputerName $PC {(Get-WmiObject -Class "Win32_Bios").SerialNumber}
        $MAC = Invoke-Command -ComputerName $PC {getmac} | Select-Object -Last 1
        $MAC = $MAC.Substring(0,18).trim()
        "$PC,$ServiceTag,$MAC"
    }else{
        "$PC, , "
    }
}