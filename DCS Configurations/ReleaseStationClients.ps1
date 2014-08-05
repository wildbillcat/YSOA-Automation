Configuration ReleaseStationsClients
{
   # This Configuration block contains a configuration for the 4th Floor Plotting Pit
   Node "ARCH-PC-219"
   {
      File InstallReleaseStation
        {
            Ensure = "Present"  # You can also set Ensure to "Absent"
            Type = "Directory" # Default is "File".
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
            SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\ARCH-PC-219.properties" # This is a path of the Updated Config File
            DestinationPath = "C:\Program Files (x86)\ReleaseStation\config.properties" # The path where the config file should be installed
            DependsOn = "[File]InstallReleaseStation" #Don't Copy the Configuration until the Release Station is installed
        }
   }

   # This Configuration block contains a configuration for the 4th Floor Manual Feed Plotter
   Node "ARCH-PC-175"
   {
      # This Copys the Config File over to the Machine
      File PaperCutConfigurationFile
      {
         Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
         Ensure = "Present"  # Ensure Config File Exists"
         SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\ARCH-PC-175.properties" # This is a path of the Updated Config File
         DestinationPath = "C:\Program Files (x86)\ReleaseStation\config.properties" # The path where the config file should be installed
      }
   }

   # This Configuration block contains a configuration for the 5th Floor Plotting Pit
   Node "ARCH-PC-43"
   {
      # This Copys the Config File over to the Machine
      File PaperCutConfigurationFile
      {
         Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
         Ensure = "Present"  # Ensure Config File Exists"
         SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\ARCH-PC-43.properties" # This is a path of the Updated Config File
         DestinationPath = "C:\Program Files (x86)\ReleaseStation\config.properties" # The path where the config file should be installed
      }
   }

   # This Configuration block contains a configuration for the 5th Floor Manual Feed Plotter
   Node "ARCH-PC-292"
   {
      # This Copys the Config File over to the Machine
      File PaperCutConfigurationFile
      {
         Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
         Ensure = "Present"  # Ensure Config File Exists"
         SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\ARCH-PC-292.properties" # This is a path of the Updated Config File
         DestinationPath = "C:\Program Files (x86)\ReleaseStation\config.properties" # The path where the config file should be installed
      }
   }

   # This Configuration block contains a configuration for the 6th Floor Plotting Pit
   Node "ARCH-PC-19"
   {
      # This Copys the Config File over to the Machine
      File PaperCutConfigurationFile
      {
         Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
         Ensure = "Present"  # Ensure Config File Exists"
         SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\ARCH-PC-19.properties" # This is a path of the Updated Config File
         DestinationPath = "C:\Program Files (x86)\ReleaseStation\config.properties" # The path where the config file should be installed
      }
   }

   # This Configuration block contains a configuration for the 6th Floor Manual Feed Plotter
   Node "ARCH-PC-20"
   {
      # This Copys the Config File over to the Machine
      File PaperCutConfigurationFile
      {
         Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
         Ensure = "Present"  # Ensure Config File Exists"
         SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\ARCH-PC-20.properties" # This is a path of the Updated Config File
         DestinationPath = "C:\Program Files (x86)\ReleaseStation\config.properties" # The path where the config file should be installed
      }
   }

   # This Configuration block contains a configuration for the 7th Floor Plotting Pit
   Node "ARCH-PC-245"
   {
      # This Copys the Config File over to the Machine
      File PaperCutConfigurationFile
      {
         Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
         Ensure = "Present"  # Ensure Config File Exists"
         SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\ARCH-PC-19.properties" # This is a path of the Updated Config File
         DestinationPath = "C:\Program Files (x86)\ReleaseStation\config.properties" # The path where the config file should be installed
      }
   }

   # This Configuration block contains a configuration for the 7th Floor Manual Feed Plotter
   Node "ARCH-PC-231"
   {
      # This Copys the Config File over to the Machine
      File PaperCutConfigurationFile
      {
         Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
         Ensure = "Present"  # Ensure Config File Exists"
         SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\ARCH-PC-20.properties" # This is a path of the Updated Config File
         DestinationPath = "C:\Program Files (x86)\ReleaseStation\config.properties" # The path where the config file should be installed
      }
   }

   # This Configuration block contains a configuration for the 3rd Floor Secure Release Station
   Node "ARCH-PC-218"
   {
      # This Copys the Config File over to the Machine
      File PaperCutConfigurationFile
      {
         Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
         Ensure = "Present"  # Ensure Config File Exists"
         SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\ARCH-PC-19.properties" # This is a path of the Updated Config File
         DestinationPath = "C:\Program Files (x86)\ReleaseStation\config.properties" # The path where the config file should be installed
      }
   }

   # This Configuration block contains a configuration for the SB Mylar Release Station
   Node "ARCH-PC-2000"
   {
      # This Copys the Config File over to the Machine
      File PaperCutConfigurationFile
      {
         Checksum = "ModifiedDate" #Ensure Config File is Latest Revision
         Ensure = "Present"  # Ensure Config File Exists"
         SourcePath = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\ARCH-PC-20.properties" # This is a path of the Updated Config File
         DestinationPath = "C:\Program Files (x86)\ReleaseStation\config.properties" # The path where the config file should be installed
      }
   }
} 
ReleaseStationsClients #This allows the script to be run and generate the MOF files.