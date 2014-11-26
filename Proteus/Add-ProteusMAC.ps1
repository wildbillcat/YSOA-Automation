param ( 
    [Parameter(Mandatory=$true, Position=0, HelpMessage="Enter the URL for the Proteus Server, ie proteus.website.com")] 
    [string] 
    $ProteusAPIURL,

    [Parameter(Mandatory=$true, Position=1, HelpMessage="Enter the API UserName for the Proteus Server")] 
    [string] 
    $ProteususerName,

    [Parameter(Mandatory=$true, Position=2, HelpMessage="Enter the API User Password for the Proteus Server ")] 
    [string] 
    $ProteusPassword,

    [Parameter(Mandatory=$true, Position=3, HelpMessage="Enter the MAC address to add")] 
    [string] 
    $MacAddress,

    [Parameter(Mandatory=$true, Position=4, HelpMessage="Enter the Description of the MAC Address")] 
    [string] 
    $Description,

    [Parameter(Mandatory=$true, Position=5, HelpMessage="Enter the administrative phone number for the MAC Address")] 
    [string] 
    $Phone,

    [Parameter(Mandatory=$true, Position=6, HelpMessage="Enter the physical buidling the MAC is located in")] 
    [string] 
    $Location,

    [Parameter(Mandatory=$true, Position=7, HelpMessage="Enter the URL for the Proteus Server, ie proteus.website.com")] 
    [string] 
    $ProteusNetwork
    )

    $ProteusAPIPath = Resolve-Path -Path ProteusAPI.dll
    [Reflection.Assembly]::LoadFile($ProteusAPIPath)

    #Ignore invalid SSL
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

    $Proteus = New-Object ProteusAPI($ProteusAPIURL)
    # login
    $Proteus.login($ProteususerName, $ProteusPassword)
    #Grab network configuration
    $ProteusConfiguration = $Proteus.getEntityByName(0, $ProteusNetwork, "Configuration")
    $ProteusConfiguration

    try{
        $ProteusMacAddressObject = $Proteus.getMACAddress($ProteusConfiguration.id, $MacAddress)
    }catch{
        "Invalid Mac Address or detail"
        break
    }

    if($ProteusMacAddressObject.id -eq 0){
    "Mac Doesnt exist in proteus, must create!"
    }else{
    "Mac already exists!"
    $ProteusMacAddressObject.properties
    break
    }

    $CurrentUser = (Get-WMIObject -class Win32_ComputerSystem).username
    $MacAddressDetails = "description=$Description|phone=$Phone|location=$Location|reg_by=$CurrentUser|"
    
   
    $Proteus.addMACAddress($ProteusConfiguration.id, $MacAddress, $MacAddressDetails)
    