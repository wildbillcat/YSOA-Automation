Get-WmiObject -Class Win32_LogicalDisk |  where {$_.DriveType -eq 3} |select DriveType,DeviceID,Size

