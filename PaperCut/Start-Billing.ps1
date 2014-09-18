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
    [Parameter(Mandatory=$TRUE, Position=6, HelpMessage="Enter the User ID given by SFAS")] 
    [string] 
    $SFASBatchUserID,

    [Parameter(Mandatory=$TRUE, Position=7, HelpMessage="Enter the Detail Code given by SFAS")] 
    [string] 
    $SFASBatchDetailCode,

    [Parameter(Mandatory=$TRUE, Position=8, HelpMessage="Enter the file prefix required by SFAS")] 
    [string] 
    $SFASBatchFilePrefix,

    #SFAS Batch SFTP Server Variables
    [Parameter(Mandatory=$TRUE, Position=9, HelpMessage="Enter the User ID for the SFAS SFTP Server")] 
    [string] 
    $SFTPUser,

    [Parameter(Mandatory=$TRUE, Position=10, HelpMessage="Enter the password for the SFTP User")] 
    [string] 
    $SFTPPassword,

    [Parameter(Mandatory=$TRUE, Position=11, HelpMessage="Enter the file path for the SFTP Key")] 
    [string] 
    $SFTPKeyPath,

    [Parameter(Mandatory=$TRUE, Position=12, HelpMessage="Enter the URL for the SFTP SFAS Server")] 
    [string] 
    $SFTPServerPath,

    [Parameter(Mandatory=$TRUE, Position=13, HelpMessage="Enter the SFTP Port for the SFTP Server")] 
    [string] 
    $SFTPPortNumber,

    [Parameter(Mandatory=$TRUE, Position=14, HelpMessage="Enter the SSH Host Key Fingerprint of the SFTP Server")] 
    [string] 
    $SSHHostKeyFingerprint,

    [Parameter(Mandatory=$TRUE, Position=15, HelpMessage="Enter the remote directory used to store the SFAS Billing")] 
    [string] 
    $RemoteDirectory,

    [Parameter(Mandatory=$TRUE, Position=16, HelpMessage="Enter the FTP protocol used by SFAS SFTP Server")] 
    [string] 
    $FileProtocol,

    [Parameter(Mandatory=$TRUE, Position=17, HelpMessage="Enter the file path to WinSCP")] 
    [string] 
    $WinSCPPath,

    #SMTP E-mail Variables
    [Parameter(Mandatory=$TRUE, Position=18, HelpMessage="Enter the URL for the Local SMTP Server")] 
    [string] 
    $SMTPServer,

    [Parameter(Mandatory=$TRUE, Position=19, HelpMessage="Enter the SMTP Port for the SMTP Server")] 
    [string] 
    $SMTPPort,

    [Parameter(Mandatory=$TRUE, Position=20, HelpMessage="Enter whether SSL is enabled on the SMTP Server")] 
    [string] 
    $SSLEnabled,

    [Parameter(Mandatory=$TRUE, Position=21, HelpMessage="Enter the User ID for the SMTP Server")] 
    [string] 
    $SMTPUser,

    [Parameter(Mandatory=$TRUE, Position=22, HelpMessage="Enter the password for the previous User ID")] 
    [string] 
    $SMTPPassword,

    [Parameter(Mandatory=$TRUE, Position=23, HelpMessage="Enter the email address the e-mail should appear from")] 
    [string] 
    $EmailFrom,

    [Parameter(Mandatory=$TRUE, Position=24, HelpMessage="Enter the email address to send the summary to")] 
    [string] 
    $EmailTo,

    [Parameter(Mandatory=$TRUE, Position=25, HelpMessage="Enable or Disable the e-mail summary of Billing")] 
    [string] 
    $SendBillingSummary
)

#Load the XML RPC Library 
$RPCAssemblyPath = Resolve-Path -Path CookComputing.XmlRpcV2.dll
[Reflection.Assembly]::LoadFile($RPCAssemblyPath)

#Load the PaperCut Library
$PaperCutAssemblyPath = Resolve-Path -Path PaperCutServer.dll
[Reflection.Assembly]::LoadFile($PaperCutAssemblyPath)

#Create a Papercut Server Interface
$PaperCutServer = new-object PaperCutRPC.PaperCutServer($PaperCutServer, $PaperCutAPIKey, $PaperCutPort)

$TotalPaperCutUsers = $PaperCutServer.GetTotalPaperCutUsers()

echo "PaperCutUsers: $TotalPaperCutUsers"

$FetchUsersSuccess = $PaperCutServer.RetrievePapercutUsers()

if($true -eq $FetchUsersSuccess){
    echo "Feching users was a success"
}else{
    echo "Fetching users failed!"
    break
}

#Test results by writing out the list of users.
Echo "List users"
foreach ($user in $PaperCutServer.GetPapercutUsers()){
    echo "$user"
}