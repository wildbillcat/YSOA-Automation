param ( 
    [Parameter(Mandatory=$false, Position=0, HelpMessage="Enter the URL for the Proteus Server, ie proteus.website.com")] 
    [string] 
    $ProteusAPIURL,

    [Parameter(Mandatory=$false, Position=0, HelpMessage="Enter")] 
    [string] 
    $ProteususerName,

    [Parameter(Mandatory=$false, Position=0, HelpMessage="Enter ")] 
    [string] 
    $ProteusPassword,

    [Parameter(Mandatory=$false, Position=0, HelpMessage="Enter ")] 
    [string] 
    $MacAddress,

    [Parameter(Mandatory=$false, Position=0, HelpMessage="Enter ")] 
    [string] 
    $Description,

    [Parameter(Mandatory=$false, Position=0, HelpMessage="Enter ")] 
    [string] 
    $Phone,

    [Parameter(Mandatory=$false, Position=0, HelpMessage="Enter ")] 
    [string] 
    $Location
    )

    $ProteusAPIPath = Resolve-Path -Path ProteusAPI.dll
    [Reflection.Assembly]::LoadFile($ProteusAPIPath)

    #Ignore invalid SSL
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

    $Proteus = New-Object ProteusAPI($ProteusAPIURL)
    # login
    $Proteus.login($ProteususerName, $ProteusPassword)
    #Grab network configuration
    $ProteusConfiguration = $Proteus.getEntityByName(0, "Yale Network", "Configuration")
    $ProteusConfiguration

    $ProteusMacAddressObject = $Proteus.getMACAddress($ProteusConfiguration.id, $MacAddress)
    


    if($ProteusMacAddressObject.id -eq 0){
    "Mac Doesnt exist in proteus, must create!"
    }else{
    "Mac already exists!"
    $ProteusMacAddressObject.properties
    break
    }

    $CurrentUser = Get-WMIObject -class Win32_ComputerSystem | select username
    $MacAddressDetails = "description=$Description|phone=$Phone|location=$Location|reg_by=$CurrentUser|"
    $Proteus.addMACAddress($ProteusConfiguration.id, $MacAddress, $MacAddressDetails)
