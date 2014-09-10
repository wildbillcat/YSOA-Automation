<#
.Synopsis
   This Finds a computer's OU in the active directory
.DESCRIPTION
   This is a script that finds the specified computers in the AD returns it's Distinguished name.
.EXAMPLE
   Get-ComputerOU.ps1 -ComputerName PC1,PC2,PC3 
.LINK
    mailto:patrick.mcmorran@yale.edu
#>
Param(
    [Parameter(Mandatory=$true)]
    [string[]]$ComputerName
)


foreach($Computer in $ComputerName){
        Get-ADComputer $Computer | select DistinguishedName
}