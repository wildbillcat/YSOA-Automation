<#
.Synopsis
   This script is used to bill user papercut balances to SFAS.
.DESCRIPTION
   This is a script that pulls user balances from a PaperCut server, Formats the information into a file to be batch processed, 
   and then uploads the file to a server for batch processing.
.EXAMPLE
   
.LINK
    mailto:patrick.mcmorran@yale.edu
#>


param (

    #Papercut Server Variables  
    [Parameter(Mandatory=$TRUE, Position=0, HelpMessage="Enter the URL for the PaperCut Server, ie papercut.website.com")] 
    [string[]] 
    $PaperCutServer, 
  
    [Parameter(Mandatory=$TRUE, Position=1, HelpMessage="Enter the API Key or Administrator Password for the PaperCut Server")] 
    [string] 
    $PaperCutAPIKey,

    [Parameter(Mandatory=$False, Position=2, HelpMessage="Enter the port number for the PaperCut Server (Default: 9191)")] 
    [int] 
    $PaperCutPort = 9191,

    #Banner Oracle Database Variables
    [Parameter(Mandatory=$TRUE, Position=3, HelpMessage="Enter the name of the Banner Server used to pull Student Information")] 
    [string] 
    $BannerOracleDatabase,

    [Parameter(Mandatory=$TRUE, Position=4, HelpMessage="Enter the username to access the Banner Server")] 
    [string] 
    $BannerOracleUser,

    [Parameter(Mandatory=$TRUE, Position=5, HelpMessage="Enter the password for the Banner User")] 
    [string] 
    $BannerOraclePassword,

    #SFAS Batch File Variables
    [Parameter(Mandatory=$TRUE, Position=6, HelpMessage="Enter the Unique ID for this SFAS Billing")] 
    [string] 
    $SFASBatchBillingID,

    [Parameter(Mandatory=$TRUE, Position=7, HelpMessage="Enter the User ID given by SFAS")] 
    [string] 
    $SFASBatchUserID,

    [Parameter(Mandatory=$TRUE, Position=8, HelpMessage="Enter the Detail Code given by SFAS")] 
    [string] 
    $SFASBatchDetailCode,

    [Parameter(Mandatory=$TRUE, Position=9, HelpMessage="Enter the file prefix required by SFAS")] 
    [string] 
    $SFASBatchFilePrefix,

    #SFAS Batch SFTP Server Variables
    [Parameter(Mandatory=$TRUE, Position=10, HelpMessage="Enter the User ID for the SFAS SFTP Server")] 
    [string] 
    $SFTPUser,

    [Parameter(Mandatory=$TRUE, Position=11, HelpMessage="Enter the password for the SFTP User")] 
    [string] 
    $SFTPPassword,

    [Parameter(Mandatory=$TRUE, Position=12, HelpMessage="Enter the file path for the SFTP Key")] 
    [string] 
    $SFTPKeyPath,

    [Parameter(Mandatory=$TRUE, Position=13, HelpMessage="Enter the URL for the SFTP SFAS Server")] 
    [string] 
    $SFTPServerPath,

    [Parameter(Mandatory=$TRUE, Position=14, HelpMessage="Enter the SFTP Port for the SFTP Server")] 
    [string] 
    $SFTPPortNumber,

    [Parameter(Mandatory=$TRUE, Position=15, HelpMessage="Enter the SSH Host Key Fingerprint of the SFTP Server")] 
    [string] 
    $SSHHostKeyFingerprint,

    [Parameter(Mandatory=$TRUE, Position=16, HelpMessage="Enter the remote directory used to store the SFAS Billing")] 
    [string] 
    $RemoteDirectory,

    [Parameter(Mandatory=$TRUE, Position=17, HelpMessage="Enter the FTP protocol used by SFAS SFTP Server")] 
    [string] 
    $FileProtocol,

    [Parameter(Mandatory=$TRUE, Position=18, HelpMessage="Enter the file path to WinSCP")] 
    [string] 
    $WinSCPPath,

    #SMTP E-mail Variables
    [Parameter(Mandatory=$TRUE, Position=19, HelpMessage="Enter the URL for the Local SMTP Server")] 
    [string] 
    $SMTPServer,

    [Parameter(Mandatory=$TRUE, Position=20, HelpMessage="Enter the SMTP Port for the SMTP Server")] 
    [string] 
    $SMTPPort,

    [Parameter(Mandatory=$TRUE, Position=21, HelpMessage="Enter whether SSL is enabled on the SMTP Server")] 
    [string] 
    $SSLEnabled,

    [Parameter(Mandatory=$TRUE, Position=22, HelpMessage="Enter the User ID for the SMTP Server")] 
    [string] 
    $SMTPUser,

    [Parameter(Mandatory=$TRUE, Position=23, HelpMessage="Enter the password for the previous User ID")] 
    [string] 
    $SMTPPassword,

    [Parameter(Mandatory=$TRUE, Position=24, HelpMessage="Enter the email address the e-mail should appear from")] 
    [string] 
    $EmailFrom,

    [Parameter(Mandatory=$TRUE, Position=25, HelpMessage="Enter the email address to send the summary to")] 
    [string] 
    $EmailTo,

    [Parameter(Mandatory=$TRUE, Position=26, HelpMessage="Enable or Disable the e-mail summary of Billing")] 
    [string] 
    $SendBillingSummary,

    #Active Directory Parameters
    [Parameter(Mandatory=$False, Position=27, HelpMessage="Enable or Disable the e-mail summary of Billing")] 
    [string[]] 
    $ADWhiteList,

    [Parameter(Mandatory=$False, Position=28, HelpMessage="Enable or Disable the e-mail summary of Billing")] 
    [string[]] 
    $ADBlackList,

    #Student Status Codes of students Valid to Bill
    #IE: {"EL", "FC", "HT", "LT", "NP"};
    [Parameter(Mandatory=$True, Position=29, HelpMessage="Enable or Disable the e-mail summary of Billing")] 
    [string[]] 
    $SFASValidStatus,

    [Parameter(Mandatory=$False, Position=30, HelpMessage="This is the path to Oracle.ManagedDataAccess.dll of the ODP.NET package installed")] 
    [string[]] 
    $OracleManagedDataAssemblyPath


)

#Validate Batch Information
$SFASBatchUserID = $SFASBatchUserID.PadRight(8," ")
if($SFASBatchDetailCode.Length -ne 8){
    echo "Invalid Batch User ID (Should be less than 9 Characters)"
}
$SFASBatchBillingID = $SFASBatchBillingID.PadLeft(5,"0")
if($SFASBatchBillingID.Length -ne 5){
    echo "Invalid Batch Detail Code (Should be less than 6 Characters)"
}
if($SFASBatchDetailCode.Length -ne 4){
    echo "Invalid Batch Detail Code (Should be 4 Characters)"
}
#Test to make sure Billing ID is valid:$SFASBatchBillingID

#Load the XML RPC Library 
$RPCAssemblyPath = Resolve-Path -Path CookComputing.XmlRpcV2.dll
[Reflection.Assembly]::LoadFile($RPCAssemblyPath)

#Load the PaperCut Library
$PaperCutAssemblyPath = Resolve-Path -Path PaperCutServer.dll
[Reflection.Assembly]::LoadFile($PaperCutAssemblyPath)

#Load the SFAS User Library
$SFASUserAssemblyPath = Resolve-Path -Path SFASUser.dll
[Reflection.Assembly]::LoadFile($SFASUserAssemblyPath)

#Load the Oracle Managed Data Access
$PaperCutAssemblyPath = Resolve-Path -Path $OracleManagedDataAssemblyPath
[Reflection.Assembly]::LoadFile($OracleManagedDataAssemblyPath)

#Create a Papercut Server Interface
$PaperCutServer = new-object PaperCutRPC.PaperCutServer($PaperCutServer, $PaperCutAPIKey, $PaperCutPort)

#Open Connection to Oracle Database
$OracleServer = New-Object Oracle.ManagedDataAccess.Client.OracleConnection("User Id=$BannerOracleUser;Password=$BannerOraclePassword;Data Source=$BannerOracleDatabase")
try{
    $OracleServer.open()
    echo "Connection to Oracle Established"
}catch{
    echo "Failed to open connection to Oracle Server!"
    break
}


#Test Connectivity by retrieving the number of users
try{
    $TotalPaperCutUsers = $PaperCutServer.GetTotalPaperCutUsers()
    echo "PaperCutUsers: $TotalPaperCutUsers"
}catch{
    echo "Failed to open connection to PaperCut Server!"
    break
}


$FetchUsersSuccess = $PaperCutServer.RetrievePapercutUsers()

if($true -eq $FetchUsersSuccess){
    echo "Feching users from PaperCut was a success"
}else{
    echo "Fetching users from PaperCut failed!"
    break
}

#Pull Master List of PaperCutUsers
$PaperCutUsers = $PaperCutServer.GetPapercutUsers();

$ActiveDirectoryBillableUsers
$BillableUsers

#Filter out Billable Users
if($ADWhiteList -ne $null){
    #Enumerate all the Whitelisted Billable Users
    foreach($UserGroup in $ADWhiteList){
        $ActiveDirectoryBillableUsers += Get-ADGroupMember $UserGroup -Recursive | select name
    }

    #Filtering out Users not on Whitelist
    foreach($User in $ActiveDirectoryBillableUsers){
        if($PaperCutUsers.Contains($User)){
            $BillableUsers += $User
        }
    }
    
    #Clear PaperCut List
    $PaperCutUsers.Clear()
    
    #Clear AD User List
    $ActiveDirectoryBillableUsers.Clear()
}else{
    $BillableUsers = $PaperCutUsers
}



if($ADBlackList -ne $null){
    #Enumerate all users not to be billed
    foreach($UserGroup in $ADBlackList){
        $ActiveDirectoryBillableUsers += Get-ADGroupMember $UserGroup -Recursive | select name
    }

    #Filtering out Users on BlackList
    foreach($User in $ActiveDirectoryBillableUsers){
        if($BillableUsers.Contains($User)){
            $BillableUsers.Remove($User)
        }
    }
}
#End Filter

#As a precaution, remove any duplicate users that might exist
$BillableUsers = $BillableUsers | select -uniq

#Retrieve a sublist of users from PaperCut with Account Balances
$BillingList = $PaperCutServer.RetrievePapercutBalances($BillableUsers);

#Now with the List of Whom to Bill Determine who CAN be billed.

#Determine what the Billing Term Code is:
$BillingTermCodeCMD = $OracleServer.CreateCommand()
$BillingTermCodeCMD.CommandText = "select current_term_code from syvctrm_with_su"
$BillingTermCodeReader = $BillingTermCodeCMD.ExecuteReader()
$BillingTermCode

if($BillingTermCodeReader.Read()){
    #A Term Code was returned!
    $BillingTermCode = $BillingTermCodeReader.GetString(0)
}else{
    #A Term Code was not returned!
    Echo "A Billing Term Code was not returned!"
    break
}


foreach($User in $BillingList){
    $BilledUserCMD = $OracleServer.CreateCommand()
    $BilledUserCMD.CommandText = "SELECT syvyids_pidm, syvyids_spriden_id, stvests_code, stvests_desc FROM syvyids, sfbetrm, stvests WHERE (syvyids_pidm = sfbetrm_pidm) AND (sfbetrm_term_code = '$BillingTermCode') AND (sfbetrm_ests_code = stvests_code) AND (syvyids_netid = '", NetID, "')"
    $BilledUserReader = $BillingTermCodeCMD.ExecuteReader()
    if($BillingTermCodeReader.Read()){
        #A Term Code was returned!
        $BillingTermCode = $BilledUserReader.GetString(0)
    }else{
        #A Term Code was not returned!
        Echo "The " + $User.NetID + " was not found in Banner Semster $BillingTermCode"
        break
    }
}

