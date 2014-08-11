#REQUIRES -Version 4.0
#REQUIRES -Module ActiveDirectory
<#
.Synopsis
   This Configures a Computer to be used as a PaperCut Release Station with the designated configuration
.DESCRIPTION
   This is a script that installs the papercut release station software, configures the computer with required 
   customizations, moves the computer in the active directory, and gpupdates it. The computer should be restarted
   manually after the DSC is applied.
.EXAMPLE
   .\ReleaseStationClients.ps1 -MachineName Arch-PC-623 -Configuration PlottingPit6
   Start-DscConfiguration .\ReleaseStationsClients -ComputerName Arch-PC-623 -Verbose -Wait
.LINK
    mailto:patrick.mcmorran@yale.edu
#>

param(
   $MachineName,
   $Configuration
   )

Configuration ReleaseStationsClients
{
   param(
   $MachineName,
   $Configuration
   )

   $UserName = "ReleaseStationUser" #This is the username stored in the GPO for Signage Machines
   $Password = "!MY573RyP@55w0rd" | ConvertTo-SecureString -asPlainText -Force #This is the password stored int he GPO for Signage Machines
   $ResourceShare = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\"
   # This Configuration block contains a configuration for the 4th Floor Plotting Pit
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

      #This copies the release station software from the DSC Share
      File InstallReleaseStation
        {
            Ensure = "Present"  
            Type = "Directory"
            Recurse = $true # Ensure presence of subdirectories, too
            Force = $true
            SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\PCRelease"
            DestinationPath = "C:\Program Files (x86)\ReleaseStation"    
        }
      
      # This Copys the Connection Config File over to the Machine
      File PaperCutConnectionConfigurationFile
        {
            Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
            Ensure = "Present"  # Ensure Config File Exists"
            SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\connection.properties" # This is a path of the Updated Connection Config File
            DestinationPath = "C:\Program Files (x86)\ReleaseStation\connection.properties" # The path where the config file should be installed
            DependsOn = "[File]InstallReleaseStation" #Don't Copy the Configuration until the Release Station is installed
        }

      # This Copys the ReleaseStation Config File over to the Machine
      File PaperCutConfigurationFile
        {
            Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
            Ensure = "Present"  # Ensure Config File Exists"
            SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\$Configuration.properties" # This is a path of the Updated Config File
            DestinationPath = "C:\Program Files (x86)\ReleaseStation\config.properties" # The path where the config file should be installed
            DependsOn = "[File]InstallReleaseStation" #Don't Copy the Configuration until the Release Station is installed
        }

      # This Copys the AutoHotKey File over to the Machine
      File DisableAltTab
        {
            Checksum = "ModifiedDate" #Ensure File is Latest Revision
            Ensure = "Present"  # Ensure Config File Exists"
            SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\1DisableAltTab.exe" # This is a path of the Updated Config File
            DestinationPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\1DisableAltTab.exe" # The path where the config file should be installed
            DependsOn = "[File]InstallReleaseStation" #Don't Copy the Configuration until the Release Station is installed
        }

        # This Copys the ReleaseStation Shortcut over to the Machine
      File ReleaseStationShortcut
        {
            Checksum = "ModifiedDate" #Ensure File is Latest Revision
            Ensure = "Present"  # Ensure Config File Exists"
            SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\2ReleaseStation.lnk" # This is a path of the Updated Config File
            DestinationPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\2ReleaseStation.lnk" # The path where the config file should be installed
            DependsOn = "[File]InstallReleaseStation" #Don't Copy the Configuration until the Release Station is installed
        }

        # This Copys the KillExplorer Batch File over to the Machine
      File KillExplorerBatchFile
        {
            Checksum = "ModifiedDate" #Ensure File is Latest Revision
            Ensure = "Present"  # Ensure Config File Exists"
            SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\3KillExplorer.bat" # This is a path of the Updated Config File
            DestinationPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\3KillExplorer.bat" # The path where the config file should be installed
            DependsOn = "[File]InstallReleaseStation" #Don't Copy the Configuration until the Release Station is installed
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

$ConfigurationData = @{  
    AllNodes = @(        
        @{    
            NodeName = $MachineName;                            
            PSDscAllowPlainTextPassword = $true;
         }
    )  
}

Move-ADObject -Identity (Get-ADComputer $MachineName).objectguid -TargetPath "OU=ReleaseStations,OU=Infrastructure,OU=Architecture,OU=Architecture,DC=yu,DC=yale,DC=edu"  
ReleaseStationsClients -MachineName $MachineName -Configuration $Configuration -configurationData $ConfigurationData