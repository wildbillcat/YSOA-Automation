<#
.Synopsis
   This script is used to make changes through proteus at the PowerShell Command Line
.LINK
    http://powershell.com/cs/media/p/33315.aspx
#>

# loads the dll and opens a session with the Bluecat WSDL
Function Get-bcLogin {
    # load the bluecat dll and set up the object
    $Proteusdll = [System.Reflection.Assembly]::LoadFile("c:\path\to\proteus.dll")
    $Proteus = New-Object ProteusAPI
    # login info
    $ProteusID = "apiuserid";$ProteusPWD = "apiuserpw"
    # Proteus API URL
    $Proteus.url = "http://proteus.mylocal.net/Services/API" # url to proteus server
    # login
    $Proteus.login($ProteusID, $ProteusPWD)
    # return the login object
    $Proteus
}

# resolves the root configurations (Mercy only has one, ID 0 and named Mercy...)
Function Get-bcRoot {
param(
    $id = 0,
    $Name = "MyDefaultRoot", # configure your default root or set this up so it prompts you
    $type = "Configuration"
)
$Proteus = Get-bcLogin
$bcRootConfig = $Proteus.getEntityByName( $id, $Name, $type )
$bcRootConfig
}

# searches for an IP range
Function Get-bcIP4Range {
param(
        [ValidateNotNullOrEmpty()]
        $IpAddress,
        [switch]$nologout,
        [switch]$APIEntity
)
Begin {
    # get logged in and built output object
    $Proteus = Get-bcLogin
    $IpPropObj = New-Object PSObject
    # resolve root
    $bcRootConfig = Get-bcRoot
}
Process {
        # find the range
        $bcipObj = $Proteus.getIPRangedByIP( $bcRootConfig.id, "IP4Block", $IpAddress ) 
    if ( $bcipObj.Type -ne $null ) {
        if ( !$APIEntity ) {
            # load the ip properties ($IpPropObj) object
            $IpPropObj | add-member -MemberType NoteProperty -Name Id -Value $bcipObj.id
            $IpPropObj | add-member -MemberType NoteProperty -Name Name -Value $bcipObj.name
            $IpPropObj | add-member -MemberType NoteProperty -Name Type -Value $bcipObj.type
            $IpPropObj | add-member -MemberType NoteProperty -Name CIDR -Value $bcipObj.CIDR
        }
        else { $IpPropObj = $bcipObj } # returns the API object 
    }
    # in case it was null
    else { 
        $IpPropObj | Add-Member -MemberType NoteProperty -Name address -Value $IpAddress 
        $IpPropObj | Add-Member -MemberType NoteProperty -Name state -Value "open" 
    } 
}
End {
    # use the $nologout switch to keep the login session alive
    if ( !$nologout ) { $Proteus.logout() }
    # return object
    $IpPropObj
}
}

# searches for an IP 
Function Get-bcIP4Address {
param(
        [ValidateNotNullOrEmpty()]
        $IpAddress,
        [switch]$nologout,
        [switch]$Range,
        [switch]$APIEntity
)
Begin {
    # get logged in and built output object
    $Proteus = Get-bcLogin
    $IpPropObj = @{} | select Id,Name,Type,address,state,leaseTime,expiryTime,macAddress
    # resolve root
    $bcRootConfig = Get-bcRoot
}
Process {
    # look up IP
    $bcipObj = $Proteus.getIP4Address( $bcRootConfig.id, $IpAddress )
    # make sure there was an object was returned
    if ( $bcipObj.Type -ne $null ) {
        if ( !$APIEntity ) {
            # load the ip properties ($IpPropObj) object
            $IpPropObj.Id = $bcipObj.id
            $IpPropObj.Name = $bcipObj.name
            $IpPropObj.Type = $bcipObj.type
            # split the 'properties' up into something readable
            $ipproperties = $bcipObj.properties.split( '|' )
            $ipproperties | % {
                $nvpair = $_.split( '=' )
                if( $nvpair ){
                    $IpPropObj.($nvpair[0].ToString()) = $nvpair[1].ToString()
                    }
                }
            } 
        else { $IpPropObj = $bcipObj } # returns the API object 
        } 
    # in case it was null
    else { 
        $IpPropObj.address = $IpAddress 
        $IpPropObj.state = "open" 
    } 
}
End {
    # use the $nologout switch to keep the login session alive
    if ( !$nologout ) { $Proteus.logout() }
    # return object
    $IpPropObj
}
}
    
# rename a Bluecat object (currently only works with ip address objects)
Function Set-bcObjectName {
param(
        [ValidateNotNullOrEmpty()] $Name,
        [ValidateNotNullOrEmpty()] $IpAddress
)
Begin {
    # get logged in
    $Proteus = Get-bcLogin
    # resolve root
    $bcRootConfig = Get-bcRoot
}
Process {
    $TrgbcIpObj = Get-bcIP4Address $IpAddress -nologout -APIEntity
    $TrgbcIpObj.name = $Name
    # update the object (can't set the 'name' in the assign routine, so 
    # you have to update the object like this)
    $Proteus.update( $TrgbcIpObj )
    $IpPropObj = Get-bcIP4Address $IpAddress
}
End {
    $IpPropObj
}
}

# reconfigure an existing reservation (or create a new one)
Function Set-bcIP4Reservation {
param  (
    [ValidateNotNullOrEmpty()] $Name,
    [ValidateNotNullOrEmpty()] $IpAddress,
    $MacAddress,
    [ValidateSet( "MAKE_DHCP_RESERVED", "MAKE_STATIC", "MAKE_RESERVED" )]
    $action = "MAKE_DHCP_RESERVED"
)
Begin {
    # get logged in and built output object
    $Proteus = Get-bcLogin
    $IpPropObj = New-Object PSObject
    # resolve root
    $bcRootConfig = Get-bcRoot
}
Process {
    # assign the IP, MAC and status ($action)
    $NewbcipObjId = $Proteus.assignIP4Address( $bcRootConfig.id, $IpAddress, $MacAddress, '', $action, '' )
    # rename the object and load output object (Set-bcObjectName returns the PowerShell/IP object not APIEntity)
    $IpPropObj = Set-bcObjectName -name $Name -ipaddress $IpAddress
}
End {
    # return the object
    $IpPropObj
}
}

# delete an existing reservation
Function Delete-bcIP4Reservation {
param( [ValidateNotNullOrEmpty()] $IpAddress )
Begin {
    # get logged in
    $Proteus = Get-bcLogin
    # resolve root
    $bcRootConfig = Get-bcRoot
}
Process {
    # resolve the ip object
    $bcipTrgObj = Get-bcIP4Address $IpAddress -nologout
    # confirm the action
	# there are more elegant ways to do this, however, this one can't be disabled with -confirm:$false
	# you must type 'y' to delete a reservation
    if ( $bcipTrgObj ) {
        Write-Host
        Write-Host "You are about to delete a DHCP configuration record for:"
        $bcipTrgObj
        $input = Read-Host -Prompt "Do you want to continue(y/n)?"
        Write-Host
    }
    if ( $input -eq 'y' ) {
        $bcipTrgDel = $Proteus.delete( $bcipTrgObj.id )
        # refresh the bc ip object
        $bcipTrgObj = Get-bcIP4Address $IpAddress
        # there is a bug in bluecat code that makes a reservation hang in 'DHCP_FREE' status
        # this next line deals with that bug by deleting the object up to 5 more times
        if ( $bcipTrgObj.state -ne 'open' ) {
            do { 
                $x += 1
                $Proteus.delete( $bcipTrgObj.id )
                [string]$IpState = ( Get-bcIP4Address $IpAddress ).state
            }
            until ( $IpState -eq 'open' -or $x -eq 5 )
            if ( $IpState -eq 'open' ) {
                Write-Host "Object deleted"
            }
            elseif ( $x = 5 ) {
                Throw "Unable to delete $IpAddress after $x attempts"
            }
        }
    }
    # in case you changed your mind
    else { 
        Throw "No changes made" 
        $bcipTrgObj
        Break
    }
    # look for the IP
    $IpPropObj = Get-bcIP4Address $IpAddress
}
End {
    # return the object
    $IpPropObj
}
}

# searches for IP addresses associated with a MAC
Function Get-bcLinkedIP {
param(
        [ValidateNotNullOrEmpty()]
        [string]$MACAddress
)
Begin {
    # get logged in and built output object
    $Proteus = Get-bcLogin
    $IpPropObj = New-Object PSObject
    # resolve root
    $bcRootConfig = Get-bcRoot
}
Process {
    # resolve the bluecat MAC object
    $bcMacObj = Get-bcMACAddress $MACAddress
    # look for associated IP4 address
    if ( $bcMacObj.state -ne 'open' ) {
        $bcLinkedObjs = $Proteus.getLinkedEntities( $bcMacObj.id, 'IP4Address', 0, 100 )
        # loop through all the linked IPs and stick them in a table
        foreach ( $AddressObj in $bcLinkedObjs ) {
            $Apprprops = $AddressObj.properties.Split( "|" )
            $IP4Address = ( $Apprprops | where { $_ -match 'address=' } ).Replace( "address=", "" )
            Get-bcIP4Address $IP4Address
        }
    }
    else { $LinkedAddrs = $bcMacObj }
}
End {}
}

# searches for a MAC address
Function Get-bcMACAddress {
param(
        [ValidateNotNullOrEmpty()]
        [string]$MACAddress,
        [switch]$nologout,
        [switch]$APIEntity,
        [switch]$SearchLinkedIPs
)
Begin {
    # get logged in and built output object
    $Proteus = Get-bcLogin
    $IpPropObj = New-Object PSObject
    # resolve root
    $bcRootConfig = Get-bcRoot
}
Process {
    # look up MAC
    $bcMACObj = $Proteus.getMACAddress( $bcRootConfig.id, ( $MACAddress.Replace( "-", "" ) ).Replace( ":", "" ) )
    # make sure there was an object was returned
    if ( $bcMACObj.Type -ne $null ) {
        if ( !$APIEntity ) {
            # load the ip properties ($IpPropObj) object
            $IpPropObj | add-member -MemberType NoteProperty -Name Id -Value $bcMACObj.id
            $IpPropObj | add-member -MemberType NoteProperty -Name Name -Value $bcMACObj.name
            $IpPropObj | add-member -MemberType NoteProperty -Name Type -Value $bcMACObj.type
            # split the 'properties' up into something readable
            $ipproperties = $bcMACObj.properties.split( '|' )
            $ipproperties | % {
                $nvpair = $_.split( '=' )
                if( $nvpair ){
                    $IpPropObj | Add-Member -MemberType NoteProperty -Name $nvpair[0] -Value $nvpair[1]
                }
            }
        }
    else { $IpPropObj = $bcMACObj } # returns the API object 
    }
    # in case it was null
    else { 
        $IpPropObj | Add-Member -MemberType NoteProperty -Name address -Value $MACAddress 
        $IpPropObj | Add-Member -MemberType NoteProperty -Name state -Value "open" 
    }
}
End {
    # use the $nologout switch to keep the login session alive
    if ( !$nologout ) { $Proteus.logout() }
    # return object
    $IpPropObj
    if ( $SearchLinkedIPs ) {
        get-bcLinkedIP $MACAddress
    }
}
}

# long getNextAvailableIP4Address( long parentId )
# parentId is the ip4 network that the ip should belong to
Function Get-bcNextAvailableIP4Address {
param ( 
    [Parameter(ParameterSetName = 'Ip' )]
    [ValidateNotNullOrEmpty()] $IpAddress,
    [Parameter(ParameterSetName = 'parentId' )]
    [ValidateNotNullOrEmpty()] $parentId
)
Begin {
    # get logged in
    $Proteus = Get-bcLogin
    # resolve root
    $bcRootConfig = Get-bcRoot
    if ( $PsCmdlet.ParameterSetName -eq "Ip" ) {
        $bcIpRange = Get-bcIP4Range $IpAddress
        $parentId = $bcIpRange.Id
    }
}
Process {
    $NextbcIp = $Proteus.getNextAvailableIP4Address( $parentId )
}
End {
    $NextbcIp
    }
}

# reserve the next available ip giving the ip network id 
# or another ip from the same range
Function Set-bcNextAvailableIP4Address {
param  (
    [ValidateNotNullOrEmpty()] $Name,
    [Parameter( ParameterSetName = 'Ip' )]
    [ValidateNotNullOrEmpty()] $IpAddress,
    [Parameter( ParameterSetName = 'parentId' )]
    [ValidateNotNullOrEmpty()] $parentId,
    [ValidateNotNullOrEmpty()] $MacAddress,
    [ValidateSet( "MAKE_DHCP_RESERVED", "MAKE_STATIC", "MAKE_RESERVED" )]
    $action = "MAKE_DHCP_RESERVED"
)
Begin {
    # get logged in and built output object
    $Proteus = Get-bcLogin
    $IpPropObj = New-Object PSObject
    # resolve root
    $bcRootConfig = Get-bcRoot
    switch ( $PsCmdlet.ParameterSetName ) {
        "Ip" {
            $NextbcIp = Get-bcNextAvailableIP4Address -IpAddress $IpAddress
        }
        "parentId" {
            $NextbcIp = Get-bcNextAvailableIP4Address -parentId $parentId
        }
    }
}
Process {
    # assign the IP, MAC and status ($action)
    $IpPropObj = Set-bcIP4Reservation -Name $Name -IpAddress $NextbcIp -MacAddress $MacAddress -action $action
}
End {
    # return the object
    $IpPropObj
}
}
