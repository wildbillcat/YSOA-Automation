<#
.Synopsis
This deletes, renames, and moves camera image files
.DESCRIPTION
This is a script that deletes the "Aged Out" Files, Renames Folders to Age out files, and the Moves new files to the new folder.
.EXAMPLE
Start-CameraAging.ps1 -RootFolder "h:\ftp" -Days 6
.LINK
mailto:patrick.mcmorran@yale.edu
#>
Param(
    [Parameter(Mandatory=$true)]
    [string]$RootFolder,
    [Parameter(Mandatory=$true)]
    [int]$Days
)

Set-Location -Path $RootFolder

$Folders = Get-ChildItem -Directory

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
        Remove-Item -Path $OldestFolderPath

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
        $NewFiles = Get-ChildItem -File  | Where-Object { $_.LastWriteTime -le [DateTime] (get-date).AddDays(-1) }
        Foreach($File in $NewFiles){
            Move-Item -Path $File -Destination $Day1Directory
            #Copy File to $Day1 Day1 Directory
        }
        #End Creation of Day 1 Folder
    }

    Start-Job -ScriptBlock $ScriptBlock   
}