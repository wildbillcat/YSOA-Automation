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
    [string[]]$RootFolder,
    [Parameter(Mandatory=$true)]
    [int]$Days
)

