<#
.Synopsis
   This fetches the Computer Model from WMI to then be used for comparison
.DESCRIPTION
   This is a script that finds the local computer's number of hard drives, spawning a job per computer for time saving. It then will write out any compuer
   in the range specified that has 1 hard disk.
.EXAMPLE
   FetchDisksOfComputerRange.ps1
.LINK
    mailto:kingrolloinc@sbcglobal.net
#>
for($i = 900; $i -le 999; $i++){
    Echo "Arch-PC-$i"
    $ScriptBlock = {
        $Disks = Invoke-Command -ComputerName "arch-pc-$using:i" { Get-WmiObject -Class Win32_LogicalDisk |  where {$_.DriveType -eq 3} |select DriveType,DeviceID,Size }
        if( $Disks.Count -eq 1 ){
            Add-Content D:\Missing.txt "`nArch-PC-$using:i"
        }elseif ($Disks -eq $null){
            Add-Content D:\Offline.txt "`nArch-PC-$using:i"
        }else{
            Add-Content D:\Online.txt "`nArch-PC-$using:i"
        }
    }
    Start-Job -ScriptBlock $ScriptBlock    
}