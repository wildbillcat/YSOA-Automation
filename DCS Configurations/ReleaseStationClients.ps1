Configuration ReleaseStationsClients
{
   param(
   $MachineName,
   $Configuration
   )
   # This Configuration block contains a configuration for the 4th Floor Plotting Pit
   Node $MachineName 
   {
      User AddSignageUser #Adds the Signage User that will AutoLogin with the GPO
        {
            UserName = "ReleaseStationUser"
            Password = "!MY573RyP@55w0rd"
            Ensure = "Present"
            PasswordChangeNotAllowed = $true
            PasswordChangeRequired = $false
            PasswordNeverExpires = $true
        }

      #This copies the release station software from arch-print
      File InstallReleaseStation
        {
            Ensure = "Present"  
            Type = "Directory"
            Recurse = $true # Ensure presence of subdirectories, too
            Force = $true
            SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\PCRelease"
            DestinationPath = "C:\Program Files (x86)\ReleaseStation"    
        }
      
      # This Copys the Config File over to the Machine
      File PaperCutConnectionConfigurationFile
        {
            Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
            Ensure = "Present"  # Ensure Config File Exists"
            SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\connection.properties" # This is a path of the Updated Connection Config File
            DestinationPath = "C:\Program Files (x86)\ReleaseStation\connection.properties" # The path where the config file should be installed
            DependsOn = "[File]InstallReleaseStation" #Don't Copy the Configuration until the Release Station is installed
        }

      # This Copys the Config File over to the Machine
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
            Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
            Ensure = "Present"  # Ensure Config File Exists"
            SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\1DisableAltTab.exe" # This is a path of the Updated Config File
            DestinationPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\1DisableAltTab.exe" # The path where the config file should be installed
            DependsOn = "[File]InstallReleaseStation" #Don't Copy the Configuration until the Release Station is installed
        }

        # This Copys the ReleaseStation Shortcut over to the Machine
      File ReleaseStationShortcut
        {
            Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
            Ensure = "Present"  # Ensure Config File Exists"
            SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\2ReleaseStation" # This is a path of the Updated Config File
            DestinationPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\2ReleaseStation" # The path where the config file should be installed
            DependsOn = "[File]InstallReleaseStation" #Don't Copy the Configuration until the Release Station is installed
        }

        # This Copys the KillExplorer Batch File over to the Machine
      File KillExplorerBatchFile
        {
            Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
            Ensure = "Present"  # Ensure Config File Exists"
            SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\3KillExplorer.bat" # This is a path of the Updated Config File
            DestinationPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\3KillExplorer.bat" # The path where the config file should be installed
            DependsOn = "[File]InstallReleaseStation" #Don't Copy the Configuration until the Release Station is installed
        }
   }
}    
ReleaseStationsClients 
#-MachineName Arch-PC-175,Arch-PC-219,Arch-PC-292,Arch-PC-43,Arch-PC-20,Arch-PC-19,Arch-PC-231,Arch-PC-245,Arch-PC-218 