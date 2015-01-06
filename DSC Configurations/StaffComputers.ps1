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
      User AddSignageUser #Adds the Signage User that will AutoLogin with the GPO
      {
        UserName = $UserName
        Password = New-Object System.Management.Automation.PSCredential ($UserName, $Password)
        Ensure = "Present"
        PasswordChangeNotAllowed = $true
        PasswordChangeRequired = $false
        PasswordNeverExpires = $true
      }
      #Adobe Flash Player
      Package AdobeFlash
      {
        Ensure = "Present"  # You can also set Ensure to "Absent"
        Path  = "$ResourceShare\install_flash_player_14_active_x.msi"
        Name = "Adobe Flash Player 14 ActiveX"
        ProductId = "15AE611F-5A40-4BD0-9291-1C6856BDB9A4"
        DependsOn = "[User]AddSignageUser"
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
      # This Copys the Config File over to the Machine
      File XiboConfigurationFile
      {
         Checksum = "SHA-1" #Ensure Config File is Latest Revision
         Ensure = "Present"  # Ensure Config File Exists"
         SourcePath = "$ResourceShare\$MachineName.config" # This is a path of the Updated Config File
         DestinationPath = "C:\Program Files (x86)\Xibo Player\XiboClient.exe.config" # The path where the config file should be installed
         DependsOn = "[Package]XiboClient"
      }
      # This Copys the Config File over to the Machine
      File XiboUserConfigurationFile
      {
         Checksum = "SHA-1" #Ensure Config File is Latest Revision
         Ensure = "Present"  # Ensure Config File Exists"
         SourcePath = "$ResourceShare\$MachineName.user.config" # This is a path of the Updated Config File
         DestinationPath = "C:\Users\signage\AppData\Local\Xibo\XiboClient.exe_Url_zclrehyrcix2bbdpnuvq15j31b1kejhn\2.0.0.0\user.config" # The path where the user config file should be installed
         DependsOn = "[Package]XiboClient"
      }
        #This runs a GPUpdate to pull down the latest Group Policy configuration
      Script GPUpdateComputer
        {
        SetScript = {         
        gpupdate /force
        }
        TestScript = { $false }
        GetScript = { <# This must return a hash table #> }          
     }
   }
}

#Move-ADObject -Identity (Get-ADComputer $MachineName).objectguid -TargetPath "OU=Signage,OU=Infrastructure,OU=Architecture,OU=Architecture,DC=yu,DC=yale,DC=edu"

SignageClients -MachineName $MachineName #This allows the script to be run and generate the MOF files.