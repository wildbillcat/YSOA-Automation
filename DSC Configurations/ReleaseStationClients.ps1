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
    mailto:kingrolloinc@sbcglobal.net
#>

param(
   $MachineName,
   $Configuration
   )

Configuration ReleaseStationClients
{
   param(
   $MachineName,
   $Configuration
   )

   $UserName = "ReleaseStationUser" #This is the username stored in the GPO for Signage Machines
   $Password = "!MY573RyP@55w0rd" | ConvertTo-SecureString -asPlainText -Force #This is the password stored int he GPO for Signage Machines
   $UserCredential = New-Object System.Management.Automation.PSCredential ($UserName, $Password)
   $ResourceShare = "\\arch-cfgmgr\PowershellDCSResources\ReleaseStation\"
   # This Configuration block contains a configuration for the 4th Floor Plotting Pit
   Node $MachineName 
   {
      Registry DisableUAC
        {
            Ensure = "Present"  # You can also set Ensure to "Absent"
            Key = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system"
            ValueName = "EnableLUA"
            ValueType = "DWord"
            ValueData = "0"
            Force = $true
        }

      User AddReleaseStationUser #Adds the Signage User that will AutoLogin with the GPO
        {
            UserName = $UserName
            Password = $UserCredential
            Ensure = "Present"
            PasswordChangeNotAllowed = $true
            PasswordChangeRequired = $false
            PasswordNeverExpires = $true
        }

        #Logs out the console connection so that no resources are in use.
      Script ForceSignageUserLogOut
        {
        SetScript = {         
            logoff 1
        }
        TestScript = { $false }
        GetScript = { <# This must return a hash table #> }
        DependsOn = "[User]AddReleaseStationUser" #Ensure the Signage user has been made, so that the command can be run          
     }

       #This copies the release station software from the DSC Share (Refactor: A better Means of determining if files need to be updated should be found, rather than deleting the whole folder)
      Script RemoveOldReleaseStation
        {
        SetScript = {         
            Remove-Item "C:\Program Files (x86)\ReleaseStation" -Recurse -Force
        }
        TestScript = { ((Test-Path "C:\Program Files (x86)\ReleaseStation") -eq $false) }
        GetScript = { <# This must return a hash table #> }
        DependsOn = "[User]AddReleaseStationUser" #Ensure the Signage user has been made, so that the command can be run
        }

      #This copies the release station software from the DSC Share
      File InstallReleaseStation
        {
            Ensure = "Present"  
            Type = "Directory"
            Checksum = "SHA-512" #Ensure Software is Latest Revision
            Recurse = $true # Ensure presence of subdirectories, too
            Force = $true
            SourcePath = "$ResourceShare\PCRelease"
            DestinationPath = "C:\Program Files (x86)\ReleaseStation"
            MatchSource = $true
            DependsOn = "[Script]RemoveOldReleaseStation" #Don't Install the Release Station until the signage user is logged out, thus preventing the use of any resources from blocking   
        }
      
      # This Copys the Connection Config File over to the Machine
      File PaperCutConnectionConfigurationFile
        {
            Checksum = "SHA-512" #Ensure Config File is Latest Revision
            Ensure = "Present"  # Ensure Config File Exists"
            SourcePath = "$ResourceShare\connection.properties" # This is a path of the Updated Connection Config File
            DestinationPath = "C:\Program Files (x86)\ReleaseStation\connection.properties" # The path where the config file should be installed
            DependsOn = "[File]InstallReleaseStation" #Don't Copy the Configuration until the Release Station is installed
        }

      # This Copys the ReleaseStation Config File over to the Machine
      File PaperCutConfigurationFile
        {
            Checksum = "SHA-512" #Ensure Config File is Latest Revision
            Ensure = "Present"  # Ensure Config File Exists"
            SourcePath = "$ResourceShare\$Configuration.properties" # This is a path of the Updated Config File
            DestinationPath = "C:\Program Files (x86)\ReleaseStation\config.properties" # The path where the config file should be installed
            DependsOn = "[File]InstallReleaseStation" #Don't Copy the Configuration until the Release Station is installed
        }

      # This Copys the AutoHotKey File over to the Machine
      File DisableAltTab
        {
            Checksum = "SHA-512" #Ensure File is Latest Revision
            Ensure = "Present"  # Ensure Config File Exists"
            SourcePath = "$ResourceShare\1DisableAltTab.exe" # This is a path of the Updated Config File
            DestinationPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\1DisableAltTab.exe" # The path where the config file should be installed
            DependsOn = "[File]InstallReleaseStation" #Don't Copy the Configuration until the Release Station is installed
        }

        # This Copys the ReleaseStation Shortcut over to the Machine
      File ReleaseStationShortcut
        {
            Checksum = "SHA-512" #Ensure File is Latest Revision
            Ensure = "Present"  # Ensure Config File Exists"
            SourcePath = "$ResourceShare\2ReleaseStation.lnk" # This is a path of the Updated Config File
            DestinationPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\2ReleaseStation.lnk" # The path where the config file should be installed
            DependsOn = "[File]InstallReleaseStation" #Don't Copy the Configuration until the Release Station is installed
        }

        # This Copys the KillExplorer Batch File over to the Machine
      File KillExplorerBatchFile
        {
            Checksum = "SHA-512" #Ensure File is Latest Revision
            Ensure = "Present"  # Ensure Config File Exists"
            SourcePath = "$ResourceShare\3KillExplorer.bat" # This is a path of the Updated Config File
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
        DependsOn = "[User]AddReleaseStationUser" #Ensure the Signage user has been made          
        }

      Script RestartComputer
        {
        SetScript = {         
            shutdown /t 0 /r /f
        }
        TestScript = { $false }
        GetScript = { <# This must return a hash table #> }
        DependsOn = @('[Script]GPUpdateComputer', '[File]KillExplorerBatchFile', '[File]PaperCutConfigurationFile', '[File]ReleaseStationShortcut', '[File]ReleaseStationShortcut', '[File]DisableAltTab', '[File]PaperCutConnectionConfigurationFile', '[Script]ForceSignageUserLogOut', '[User]AddReleaseStationUser', '[Registry]DisableUAC') #Ensure everything is complete before restarting          
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

#Move-ADObject -Identity (Get-ADComputer $MachineName).objectguid -TargetPath "OU=ReleaseStations,OU=Infrastructure,OU=Architecture,OU=Architecture,DC=yu,DC=yale,DC=edu"  
ReleaseStationClients -MachineName $MachineName -Configuration $Configuration -configurationData $ConfigurationData