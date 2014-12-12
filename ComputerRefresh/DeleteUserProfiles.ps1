#Fetch List of user profiles
$Profiles = Get-CimInstance win32_userprofile 

foreach($Profile in $Profiles){
    $ProfilePath = $Profile.LocalPath
    if($ProfilePath.StartsWith("C:\Users\") -and -Not ($ProfilePath.EndsWith("vcg5") -or $ProfilePath.EndsWith("pem4"))){
        "Delete: $ProfilePath"
        $Profile | Remove-CimInstance
    }
}