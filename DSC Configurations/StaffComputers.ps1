#REQUIRES -Version 4.0
<#
.Synopsis
   This Configures a Computer to be used as a Staff PC
.DESCRIPTION
   This script contains node configurations for the staff image.
.EXAMPLE
   .\SignageClients.ps1 -MachineName ARCH-SIGNAGE-03 -Configuration ARCH-SIGNAGE-03
   Start-DscConfiguration .\ReleaseStationsClients -ComputerName ARCH-SIGNAGE-03 -Verbose -Wait
   Invoke-Command -ComputerName ARCH-SIGNAGE-03 {shutdown -t 0 -r}
   Start-DscConfiguration .\ReleaseStationsClients -ComputerName ARCH-SIGNAGE-03 -Verbose -Wait
.LINK
    mailto:patrick.mcmorran@yale.edu
#>

param(
   $MachineName
   )

Configuration StaffComputers
{
    param(
    $MachineName
    )
   
   $ResourceShare = "\\arch-cfgmgr\PowershellDCSResources\StaffImage"

   Node $MachineName 
   {
      User RemoveAdmin #Adds the Signage User that will AutoLogin with the GPO
      {
        UserName = "Admin"
        Ensure = "Absent"
      }
      #Oracle Java 32 Bit
      Package Java7u45
      {
        Ensure = "Present"  # You can also set Ensure to "Absent"
        Path  = "$ResourceShare\jre-7u45-windows-i586.exe"
        Name = "Java 7 Update 45"
      }
      #Xibo Client Package
      Package XiboClient
      {
        Ensure = "Present"  # You can also set Ensure to "Absent"
        Path  = "$ResourceShare\xibo-client-1.6.3-win32-x86.msi"
        Name = "Xibo Player"
        ProductId = "8A4B377C-D3D9-41A8-A6C5-E5CA9F8B404E"
        DependsOn = "[Package]AdobeFlash"
      } 
      
   }
}

#Move-ADObject -Identity (Get-ADComputer $MachineName).objectguid -TargetPath "OU=Signage,OU=Infrastructure,OU=Architecture,OU=Architecture,DC=yu,DC=yale,DC=edu"

SignageClients -MachineName $MachineName #This allows the script to be run and generate the MOF files.