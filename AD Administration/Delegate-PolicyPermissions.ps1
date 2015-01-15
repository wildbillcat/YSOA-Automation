$MyGPOs = Get-GPO -All | Where-Object {$_.Owner -eq "$env:USERDOMAIN\$env:USERNAME"}

ForEach($Policy in $MyGPOs){
   $Policy | Set-GPPermissions -TargetName "SOA Admins" -TargetType Group -PermissionLevel GpoEditDeleteModifySecurity -Replace
}