<#  
.Synopsis  
    This is a general template that uses two lists to then perform actions. 
     
.Description  
    Whipped this up for Rob to compare two student lists and perform actions on them.
   
.Notes  
    Name     : ActionFilterScript.ps1  
     
#>

#Read Computer Numbers and build list of unlocked computers 
$UnlockedList = Get-Content "UnlockedComputers.txt"
$UnlockedComputers = @();
foreach($PCNumber in $UnlockedList){
    $UnlockedComputers += "arch-pc-$PCNumber"
}

#Evaluate 4th Floor Computers
$FourthFloorComputers = Get-ADComputer -SearchBase 'OU=SOA 4th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu' -Filter '*' | select -ExpandProperty name
foreach($PC in $FourthFloorComputers){
    if ($UnlockedComputers -contains $PC){
    #Do stuff to the PC that Exists on the Filter List and Master List
    echo "$PC is on the Unlocked list"
    Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 4th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
    }
    else{
    echo "$PC is not on the Unlocked list"
    Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 4th Floor Studio Workstations - No Access,OU=SOA 4th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
    #Do stuff to netID that Exists on Filter List and not Master List
    }
    echo "Queue GPUpdate for $PC"
    Invoke-Command -AsJob -ComputerName $PC {gpupdate /force}
}

#Evaluate 5th Floor Computers
$FifthFloorComputers = Get-ADComputer -SearchBase 'OU=SOA 5th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu' -Filter '*' | select -ExpandProperty name
foreach($PC in $FifthFloorComputers){
    if ($UnlockedComputers -contains $PC){
    #Do stuff to the netID that Exists on the Filter List and Master List
    echo "$PC is on the Unlocked list"
    Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 5th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
    }
    else{
    echo "$PC is not on the Locked list"
    Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 5th Floor Studio Workstations - No Access,OU=SOA 5th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
    #Do stuff to netID that Exists on Filter List and not Master List
    }
    echo "Queue GPUpdate for $PC"
    Invoke-Command -AsJob -ComputerName $PC {gpupdate /force}
}

#Evaluate 6th Floor Computers
$SixthFloorComputers = Get-ADComputer -SearchBase 'OU=SOA 6th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu' -Filter '*' | select -ExpandProperty name
foreach($PC in $SixthFloorComputers){
    if ($UnlockedComputers -contains $PC){
    #Do stuff to the netID that Exists on the Filter List and Master List
    echo "$PC is on the Unlocked list"
    Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 6th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
    }
    else{
    echo "$PC is not on the Unlocked list"
    Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 6th Floor Studio Workstations - No Access,OU=SOA 6th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
    #Do stuff to netID that Exists on Filter List and not Master List
    }
    echo "Queue GPUpdate for $PC"
    Invoke-Command -AsJob -ComputerName $PC {gpupdate /force}
}

#Evaluate 7th Floor Computers
$SeventhFloorComputers = Get-ADComputer -SearchBase 'OU=SOA 7th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu' -Filter '*' | select -ExpandProperty name
foreach($PC in $SeventhFloorComputers){
    if ($UnlockedComputers -contains $PC){
    #Do stuff to the netID that Exists on the Filter List and Master List
    echo "$PC is on the Unlocked list"
    Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 7th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
    }
    else{
    echo "$PC is not on the Unlocked list"
    Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 7th Floor Studio Workstations - No Access,OU=SOA 7th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
    #Do stuff to netID that Exists on Filter List and not Master List
    }
    echo "Queue GPUpdate for $PC"
    Invoke-Command -AsJob -ComputerName $PC {gpupdate /force}
}