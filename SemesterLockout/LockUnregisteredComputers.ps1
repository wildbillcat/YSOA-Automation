#REQUIRES -Version 4.0
#REQUIRES -Module ActiveDirectory
<#  
.Synopsis  
    This script reads from a text file (UnlockedComputers.txt) a list of all numbers that have been unlocked by registration and modifies the Active Directory. 
     
.Description  
    Whipped this up to automate locking/unlocking computers quickly. Fill a text file with a list of the PC numbers separated by linebreaks. Run with the Mode 
    "SET" parameter in order to make the changes.
.EXAMPLE
    .\LockUnregisteredComputers.ps1 -Mode "SET"
.LINK
    mailto:kingrolloinc@sbcglobal.net
#>

param(
   [Parameter(Mandatory=$FALSE, Position=0, HelpMessage="If this is equals SET then the changes will actually be written to the AD and jobs queued to update the PCs.")] 
    [string] 
    $Mode = "unset"
   )

$SET = $FALSE 
if("SET" -eq $Mode){
    $SET = $TRUE
}

#Read Computer Numbers and build list of unlocked computers 
$UnlockedList = Get-Content "UnlockedComputers.txt"
$UnlockedComputers = @();
foreach($PCNumber in $UnlockedList){
    $UnlockedComputers += "arch-pc-$PCNumber"
}

#Evaluate 4th Floor Computers
$FourthFloorComputers = Get-ADComputer -SearchBase 'OU=SOA 4th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu' -Filter '*' | select -ExpandProperty name
echo "Starting 4th Floor Computer List"
foreach($PC in $FourthFloorComputers){
    if ($UnlockedComputers -contains $PC){
    #Do stuff to the PC that Exists on the Unlocked List
    echo "$PC is on the Unlocked list"
    if($SET){
        Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 4th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
        }
    }
    else{
    #Do stuff to the PC that does not exist on the Unlocked List
    echo "$PC is not on the Unlocked list"
    if($SET){
        Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 4th Floor Studio Workstations - No Access,OU=SOA 4th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
        }
    }
    echo "Queue GPUpdate for $PC"
    if($SET){
        Invoke-Command -AsJob -ComputerName $PC {gpupdate /force}
        }
}

#Evaluate 5th Floor Computers
$FifthFloorComputers = Get-ADComputer -SearchBase 'OU=SOA 5th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu' -Filter '*' | select -ExpandProperty name
echo "Starting 5th Floor Computer List"
foreach($PC in $FifthFloorComputers){
    if ($UnlockedComputers -contains $PC){
    #Do stuff to the PC that Exists on the Unlocked List
    echo "$PC is on the Unlocked list"
    if($SET){
        Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 5th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
        }
    }
    else{
    #Do stuff to the PC that does not exist on the Unlocked List
    echo "$PC is not on the Locked list"
    if($SET){
        Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 5th Floor Studio Workstations - No Access,OU=SOA 5th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
        }
    }
    echo "Queue GPUpdate for $PC"
    if($SET){
        Invoke-Command -AsJob -ComputerName $PC {gpupdate /force}
        }
}

#Evaluate 6th Floor Computers
$SixthFloorComputers = Get-ADComputer -SearchBase 'OU=SOA 6th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu' -Filter '*' | select -ExpandProperty name
echo "Starting 6th Floor Computer List"
foreach($PC in $SixthFloorComputers){
    if ($UnlockedComputers -contains $PC){
    #Do stuff to the PC that Exists on the Unlocked List
    echo "$PC is on the Unlocked list"
    if($SET){
        Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 6th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
        }
    }
    else{
    #Do stuff to the PC that does not exist on the Unlocked List
    echo "$PC is not on the Unlocked list"
    if($SET){
        Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 6th Floor Studio Workstations - No Access,OU=SOA 6th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
        }
    }
    echo "Queue GPUpdate for $PC"
    if($SET){
        Invoke-Command -AsJob -ComputerName $PC {gpupdate /force}
        }
}

#Evaluate 7th Floor Computers
$SeventhFloorComputers = Get-ADComputer -SearchBase 'OU=SOA 7th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu' -Filter '*' | select -ExpandProperty name
echo "Starting 7th Floor Computer List"
foreach($PC in $SeventhFloorComputers){
    if ($UnlockedComputers -contains $PC){
    #Do stuff to the PC that Exists on the Unlocked List
    echo "$PC is on the Unlocked list"
    if($SET){
        Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 7th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
        }
    }
    else{
    #Do stuff to the PC that does not exist on the Unlocked List
    echo "$PC is not on the Unlocked list"
    if($SET){
        Move-ADObject -Identity (Get-ADComputer $PC).objectguid -TargetPath "OU=SOA 7th Floor Studio Workstations - No Access,OU=SOA 7th Floor Studio Workstations,OU=Lab Computers,OU=Architecture,DC=yu,DC=yale,DC=edu"
        }
    }
    echo "Queue GPUpdate for $PC"
    if($SET){
        Invoke-Command -AsJob -ComputerName $PC {gpupdate /force}
        }
}