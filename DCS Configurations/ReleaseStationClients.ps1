Configuration ReleaseStationsClients
{
   param ($MachineName)
   # This Configuration block contains a configuration for the 4th Floor Plotting Pit
   Node $MachineName 
   {
      #This copies the release station software from arch-print
      File InstallReleaseStation
        {
            Ensure = "Present"  
            Type = "Directory"
            Recurse = true # Ensure presence of subdirectories, too
            Force = true
            SourcePath = "\\papercut.yu.yale.edu\PCRelease"
            DestinationPath = "C:\Program Files (x86)\ReleaseStation"    
        }

      # This Copys the Config File over to the Machine
      File PaperCutConfigurationFile
        {
            Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
            Ensure = "Present"  # Ensure Config File Exists"
            SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\$MachineName.properties" # This is a path of the Updated Config File
            DestinationPath = "C:\Program Files (x86)\ReleaseStation\config.properties" # The path where the config file should be installed
            DependsOn = "[File]InstallReleaseStation" #Don't Copy the Configuration until the Release Station is installed
        }
   }
}    
ReleaseStationsClients -MachineName Arch-PC-175,Arch-PC-219,Arch-PC-292,Arch-PC-43,Arch-PC-20,Arch-PC-19,Arch-PC-231,Arch-PC-245,Arch-PC-218 #This allows the script to be run and generate the MOF files.