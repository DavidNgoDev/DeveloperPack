Write-Host " ____________________________________________________________________________ " -ForegroundColor Green 
Write-Host "|                                                                            |" -ForegroundColor Green
Write-Host "| [+]            Applying Config Settings to Windows Terminal!           [+] |" -ForegroundColor Green
Write-Host "|____________________________________________________________________________|" -ForegroundColor Green 

# Check to make sure script is run as administrator
Write-Host "[+] Checking if script is running as administrator.."
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )
if (-Not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "`t[ERR] Please run this script as administrator`n" -ForegroundColor Red
  Read-Host  "Press any key to continue"
  exit
}
else {
	Write-Host "[+] Script is running in Admin Mode [+]"
}



Write-Output "`n The installation was a success. Press any key to acknowledge!"
[Console]::ReadKey($true) | Out-Null