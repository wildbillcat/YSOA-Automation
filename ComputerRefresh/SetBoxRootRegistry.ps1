gpupdate /force
New-ItemProperty -Path HKLM:\SOFTWARE\Box\BoxSync -Name SyncRootFolder –Force -Value 'd:\%username%\'