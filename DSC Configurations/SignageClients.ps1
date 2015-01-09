#REQUIRES -Version 4.0
<#
.Synopsis
   This Configures a Computer to be used as a Signage PC with the designated configuration
.DESCRIPTION
   This is a script that installs the Xibo Signage software, Flash, configures the computer with required 
   customizations, moves the computer in the active directory, and gpupdates it. The computer should be restarted
   manually after the DSC is applied. This configuration has to be run twice, first to add the User and Flash, 
   restarting, then run again to install Xibo and configure it.
.EXAMPLE
   .\SignageClients.ps1 -MachineName ARCH-SIGNAGE-03 -Configuration ARCH-SIGNAGE-03
   Start-DscConfiguration .\SignageClients -ComputerName ARCH-SIGNAGE-03 -Verbose -Wait
   Invoke-Command -ComputerName ARCH-SIGNAGE-03 {shutdown -t 0 -r}
   Start-DscConfiguration .\SignageClients -ComputerName ARCH-SIGNAGE-03 -Verbose -Wait
.LINK
    mailto:patrick.mcmorran@yale.edu
.DEVEL
    For getting an installed program's guid (for xibo client) you can use the following powershell command:
    Get-WmiObject -Class Win32_Product
#>

param(
   $MachineName
   )

Configuration SignageClients
{
    param(
    $MachineName
    )
   
   $UserName = "signage" #This is the username stored in the GPO for Signage Machines
   $Password = "!MY573RyP@55w0rd" | ConvertTo-SecureString -asPlainText -Force #This is the password stored int he GPO for Signage Machines
   $ResourceShare = "\\arch-cfgmgr\PowershellDCSResources\Signage"

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
      #Force Signage User Logout
      Script ForceSignageUserLogOut
        {
        SetScript = {         
            logoff 1
        }
        TestScript = { $false }
        GetScript = { <# This must return a hash table #> }
        DependsOn = "[Package]AdobeFlash" #Ensure the Signage user has been made, so that the command can be run          
     }
      #Xibo Client Package
      Package XiboClient
      {
        Ensure = "Present"  # You can also set Ensure to "Absent"
        Path  = "$ResourceShare\xibo-client-1.6.4-win32-x86.msi"
        Name = "Xibo Player"
        ProductId = "67C8DFA6-60E7-4FAE-AF53-286B6A337F1B"
        DependsOn = "[Script]ForceSignageUserLogOut"
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

$ConfigurationData = @{  
    AllNodes = @(        
        @{    
            NodeName = $MachineName;                            
            PSDscAllowPlainTextPassword = $true;
         }
    )  
}

SignageClients -MachineName $MachineName -configurationData $ConfigurationData #This allows the script to be run and generate the MOF files.