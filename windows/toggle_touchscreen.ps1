# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
{
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
}
else
{
   # We are not running "as Administrator" - so relaunch as administrator

   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;

   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";

   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);

   # Exit from the current, unelevated, process
   exit
}

$touchscreen = Get-PnpDevice -FriendlyName "HID-compliant touch screen"
if($touchscreen.Status -eq "OK") {
   Write-Host -NoNewLine "Touchscreen currently enabled, attemting to disable... "
   $touchscreen | Disable-PnpDevice -confirm:$false
   Start-Sleep -s 1
   $touchscreen = Get-PnpDevice -FriendlyName "HID-compliant touch screen"
   if($touchscreen.Status -eq "Error") {
       Write-Host "success."
   } else {
       Write-Host "error, please see your nearest local Googley-bear."
   }
} else {
   Write-Host -NoNewLine "Touchscreen currently disabled, attempting to enable... "
   $touchscreen | Enable-PnpDevice -confirm:$false
   Start-Sleep -s 1
   $touchscreen = Get-PnpDevice -FriendlyName "HID-compliant touch screen"
   if($touchscreen.Status -eq "OK") {
       Write-Host "success."
   } else {
       Write-Host "error, please see your nearest local Googley-bear."
   }
}
