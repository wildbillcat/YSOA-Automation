<#
.Synopsis
This deletes, renames, and moves camera image files
.DESCRIPTION
This is a script that deletes the "Aged Out" Files, Renames Folders to Age out files, and the Moves new files to the new folder.
.EXAMPLE
Start-CameraAging.ps1 -RootFolder "h:\ftp" -Days 6 -AdministratorEmails patrick@website.com,admin@website.com
.LINK
mailto:patrick.mcmorran@yale.edu
#>
Param(
    [Parameter(Mandatory=$true)]
    [string]$RootFolder,
    [Parameter(Mandatory=$true)]
    [int]$Days,
    [Parameter(Mandatory=$false)]
    [int]$MaxJobs = 4,
    [Parameter(Mandatory=$true)]
    [string[]]$AdministratorEmails,
    [Parameter(Mandatory=$true)]
    [string]$SMTPServer
)

Set-Location -Path $RootFolder

$Folders = Get-ChildItem -Directory
$Jobs = @()
$i = 0
ForEach($Folder in $Folders){
#Create a Job for each specific Folder
    $ScriptBlock = {
    Set-Location -Path $using:RootFolder
    Set-Location -Path $using:Folder

        #Validates Structure of Folder
        for($i = 1; $i -le $using:Days; $i++){
            $DirectoryPath = [string]::Concat($i,"dayold")
            echo $DirectoryPath
            if($false -eq (Test-Path $DirectoryPath)){
                #Test to ensure enough folders are made for the specified number of days. If not Create the folder
                New-Item -ItemType directory -Path $DirectoryPath
            }
        }#End Folder Validation
        
        #Remove the Oldest Folder Acceptable
        $OldestFolderPath = [string]::Concat($using:Days,"dayold")
        Remove-Item -Path $OldestFolderPath -Recurse -Force

        #Migrate Folders
         for($i = $using:Days; $i -gt 1; $i--){
            $NewName = [string]::Concat($i,"dayold")
            $NewPath = [string]::Concat($NewName)            
            $OldNum = $i - 1
            $OldPath = [string]::Concat($OldNum,"dayold")
            if($false -eq (Test-Path $NewPath)){
                #Test to ensure the New Path does not yet exist
                Rename-Item $OldPath $NewName
            }
        }#End Folder Migration

        #Create the Last Folder (Day 1)
        $Day1Directory = "1dayold"
        New-Item -ItemType directory -Path $Day1Directory #Find a way to filter everything to within 24hours?
        $NewFiles = Get-ChildItem -File  | Where-Object { $_.LastWriteTime -le [DateTime] (Get-Date -Hour 0 -Minute 0 -Second 0) }
        Foreach($File in $NewFiles){
            Move-Item -Path $File -Destination $Day1Directory
            #Copy File to $Day1 Day1 Directory
        }
        #End Creation of Day 1 Folder
        #Send Warning E-mail if photos are missing:
        if(($NewFiles -eq $null) -or ($NewFiles.Length -eq 0)){
            $Subject = "Warning, Cameral Folder $using:Folder is missing new pictures"
            $From = [string]::Concat("PowershellCameraScript@",$env:COMPUTERNAME,".",$env:USERDNSDOMAIN)
            Send-MailMessage -To $AdministratorEmails -Subject $Subject -SmtpServer $SMTPServer -From $From
        }
    }
    $Jobs += Start-Job -ScriptBlock $ScriptBlock
    
    #This section used to throttle system resources   
    $i++
    #Max concurrent job counter:
    if($i -ge $MaxJobs){
        #Wait for current number of jobs to Complete
        Wait-Job -Job $Jobs
        #ResetJobs Counter and List
        $Jobs = @()
        $i = 0
    }
}

Wait-Job -Job $Jobs