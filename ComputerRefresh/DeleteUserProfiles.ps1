#Fetch List of user profiles
$Profiles = Get-CimInstance win32_userprofile 

foreach($Profile in $Profiles){
    $ProfilePath = $Profile.LocalPath
    if($ProfilePath.StartsWith("C:\Users\") -and -Not ($ProfilePath.EndsWith("vcg5") -or $ProfilePath.EndsWith("pem4"))){
        "Delete Profile: $ProfilePath"
        $Profile | Remove-CimInstance
    }
}

$Folders = Get-Item -Path "C:\Users\*"

ForEach($Folder in $Folders){
    if(-Not (($Folder.Name -eq "vcg5") -or ($Folder.Name -eq "pem4") -or $Folder.Name -eq "Public")){
        "Delete Folder: $Folder"
        $Folder | Remove-Item -Force -Recurse
    }    
}