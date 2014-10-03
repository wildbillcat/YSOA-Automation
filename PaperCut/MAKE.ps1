<#
.Synopsis
   This script is used to check the prerequisites for the application and build any requred extensions.
.DESCRIPTION
   This is a script that checks prerequisites of the system to see if the billing script can be run. This
   was of course amusingly titled since it's purpose is similar to that of some linux applications when
   compiling from source, which the billing script requires the end user to do.
.EXAMPLE
   
.LINK
    mailto:patrick.mcmorran@yale.edu
#>

#First, test for all the resources and compile the C# code that was going to be used by this script.
if($false -eq (Test-Path CookComputing.XmlRpcV2.dll)){
    echo "Please download the CookComputing.XmlRpcV2.dll XMLRPC C# Library and place it into the folder with this script"
    echo "Located: http://xml-rpc.net/"
    break
}

if($false -eq (Test-Path ServerCommandProxy.cs)){
    echo "Please download the ServerCommandProxy.cs XMLRPC C# Library and place it into the folder with this script" 
    echo "Located: %PapercutServerInstallationDirectory%\server\examples\webservices\csharp\ServerCommandProxy.cs"
    break
}

if($false -eq (Test-Path PaperCutServer.cs)){
    echo "Please ensure the PaperCutServer.cs XMLRPC C# Library and place it into the folder with this script"
    echo "Located: YSOA-Automation\PaperCut\PaperCutServer.cs"
    break
}

if($false -eq (Test-Path SFASUser.cs)){
    echo "Please ensure the SFASUser.cs is in the folder with this script"
    echo "Located: YSOA-Automation\PaperCut\SFASUser.cs"
    break
}

$compiler = $null

if($true -eq (Test-Path "C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe")){
#.Net 4.0 Compiler is installed
    "Found 4.0 compiler for C#"
    $compiler = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
}else{
    ".Net 4.0 was not found. Can not compile C# Librarys"
    break
}


#Seems all the resources are available, build a library.
"Compiling Papercut Interface Library"
& $compiler /target:library /reference:CookComputing.XmlRpcV2.dll PaperCutServer.cs ServerCommandProxy.cs

if($true -eq (Test-Path "PaperCutServer.dll")){
    echo "Successfully compiled the Papercut Server Interface Library PaperCutServer.dll"
}else{
    echo "Failed to compile the Papercut Server Interface Library PaperCutServer.dll"
}

"Compiling Banner Formatting Library"
& $compiler /target:library SFASUser.cs

if($true -eq (Test-Path "SFASUser.dll")){
    echo "Successfully compiled the SFAS User Library SFASUser.dll"
}else{
    echo "Failed to compile the SFAS User Library SFASUser.dll"
}