#REQUIRES -Version 4.0
<#
.Synopsis
   This Configures a Computer to be a Secondary Print Server for PaperCut
.DESCRIPTION
   This is a script that installs the Papercut Secondary Print Server Software. This script in
   particular will be geared toward laser cutters, eventually setting up the lasercutter itself.
.EXAMPLE
   .\LaserCutterComputers.ps1 -MachineName ARCH-PC-303
   Start-DscConfiguration .\LaserCutterComputers -ComputerName ARCH-PC-303 -Verbose -Wait
.LINK
    mailto:patrick.mcmorran@yale.edu
#>

param(
   $MachineName
   )

Configuration LaserCutterComputers
{
    param(
    $MachineName
    )
   
   $ResourceShare = "\\arch-cfgmgr\PowershellDCSResources\LaserCutter"

   Node $MachineName 
   {
      #PaperCut Server Package
      #http://www.papercut.com/products/ng/manual/apdx-tools-installer-options.html
      Package XiboClient
      {
        Ensure = "Present"  # You can also set Ensure to "Absent"
        Path  = "$ResourceShare\pcmf-setup-14.2.27858.exe"
        Name = "PaperCut MF 14.2"
        ProductId = ""
        Arguments = "/VERYSILENT /TYPE=secondary_print /NOICONS"
      } 
   }
}


LaserCutterComputers -MachineName $MachineName #This allows the script to be run and generate the MOF files.