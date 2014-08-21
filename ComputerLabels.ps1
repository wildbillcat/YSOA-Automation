$computers = Get-ADComputer -SearchBase 'OU=T3610,OU=3DPrinting,OU=Infrastructure,OU=Architecture,OU=Architecture,DC=yu,DC=yale,DC=edu' -Filter '*' | select -ExpandProperty name

foreach($PC in $computers) { 
if (Test-Connection -ComputerName $PC -Quiet) {
        $ServiceTag = Invoke-Command -ComputerName $PC {(Get-WmiObject -Class "Win32_Bios").SerialNumber}
        $MAC = Invoke-Command -ComputerName $PC {getmac} | Select-Object -Last 1
        $MAC = $MAC.Substring(0,18).trim()
        "$PC,$ServiceTag,$MAC" | Add-Content -Path "ComputerLabels.csv"
    }else{
        "$PC, , " | Add-Content -Path "ComputerLabels.csv"
    }
}