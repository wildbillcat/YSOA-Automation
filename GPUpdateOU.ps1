$PCs = Get-ADComputer -SearchBase 'OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu' -Filter '*' | select -ExpandProperty name
$Jobs = @()
foreach($PC in $PCs){
    $Jobs += Invoke-Command -AsJob -ComputerName $PC {gpupdate /force}
    "Started GP Update on $PC"
}
"Waiting for Jobs to Complete"
Wait-Job -Job $Jobs