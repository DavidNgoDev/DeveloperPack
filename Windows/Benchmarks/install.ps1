Write-Host " ____________________________________________________________________________ " -ForegroundColor Green 
Write-Host "|                                                                            |" -ForegroundColor Green
Write-Host "| [+]           Installing Prerequisite Binaries | Please Wait           [+] |" -ForegroundColor Green
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

Write-Host " [-=-=- Installing Chocolatey -=-=-=] " -ForegroundColor Green 
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install furmark -y
choco install msiafterburner -y
choco install crystaldiskmark -y
choco install superbenchmarker -y
choco install aida64-extreme -y
choco install cinebench -y
choco install heaven-benchmark -y
choco install intel-xtu -y

Write-Output "`n The installation was a success. Press any key to acknowledge!"
[Console]::ReadKey($true) | Out-Null