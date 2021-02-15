Write-Host " ____________________________________________________________________________ " -ForegroundColor Green 
Write-Host "|                                                                            |" -ForegroundColor Green
Write-Host "| [+]              Running Prerequisite Scan | Please Wait!              [+] |" -ForegroundColor Green
Write-Host "|____________________________________________________________________________|" -ForegroundColor Green 

# Check for internet connection
while (!(test-connection 8.8.8.8 -Count 1 -Quiet)) {
    Write-Host "[+] No Internet Detected [+]" -ForegroundColor Red
    Write-Host "[+] Please connect to the internet and try again! [+]" -ForegroundColor Red
    Write-Host "[+] Press any key to exit!!! [+]" -ForegroundColor Red
    [Console]::ReadKey($true) | Out-Null
    exit
}

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

# Check to make sure host has been updated
  Write-Host "[+] Checking if host has been configured with updates"
  if (-Not (get-hotfix | where { (Get-Date($_.InstalledOn)) -gt (get-date).adddays(-30) })) {
    try 
    {
      Write-Host "[WARNING] You must update this machine to continue! Do you want to try installing updates automatically? Y/N " -ForegroundColor Yellow -NoNewline
      $response = Read-Host
      if ($response -eq "Y"){
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        Install-Module PSWindowsUpdate -Force
        Import-Module PSWindowsUpdate
        Get-WindowsUpdate
        Install-WindowsUpdate -AcceptAll -IgnoreReboot -IgnoreRebootRequired
      } else {
        Write-Host "Please install updates manually." -ForegroundColor Red
        exit
      }
    }
    catch 
    {
      Write-Host "[WARNING] Could not update automatically, please run Windows Updates manually to continue`n" -ForegroundColor Red
      Read-Host  "Press any key to exit"
      exit
      
    }
    
  } else {
	  Write-Host "[+] Updates appear to be in order [+]" -ForegroundColor Green
  }

  #Check to make sure host has enough disk space
  Write-Host "[+] Checking if host has enough disk space [+]"
  $disk = Get-PSDrive C
  Start-Sleep -Seconds 1
  if (-Not (($disk.used + $disk.free)/1GB -gt 128)){
    Write-Host "`[WARNING] This install requires a minimum 128 GB hard drive, please increase hard drive space to continue`n" -ForegroundColor Red
    Read-Host "Press any key to continue"
    exit
  } else {
    Write-Host "[+] 128 GB hard drive. looks good [+]" -ForegroundColor Green
  }

Write-Host " ____________________________________________________________________________ " -ForegroundColor Green 
Write-Host "|                                                                            |" -ForegroundColor Green
Write-Host "| [+]           Installing Prerequisite Binaries | Please Wait           [+] |" -ForegroundColor Green
Write-Host "|____________________________________________________________________________|" -ForegroundColor Green 

Write-Host " [-=-=- Installing Chocolatey -=-=-=] " -ForegroundColor Green 
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Write-Host " [-=-=- Installing Scoop -=-=-=] " -ForegroundColor Green 
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
Write-Host " [-=-=- Installing BoxStarter -=-=-=] " -ForegroundColor Green 
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1')); Get-Boxstarter -Force

Write-Host " ____________________________________________________________________________ " -ForegroundColor Green 
Write-Host "|                                                                            |" -ForegroundColor Green
Write-Host "| [+]               Applying Local Settings | Please Wait!               [+] |" -ForegroundColor Green
Write-Host "|____________________________________________________________________________|" -ForegroundColor Green

# AUS Time Settings Change Here For Your Location
Set-TimeZone -Name "AUS Eastern Standard Time"
Write-Host "[+] Time Zone Set To AEST [+]" -ForegroundColor Yellow

#--- Windows Desktop Experience Settings  ---
Write-Host "[+] Settings Desktop Experience Settings [+]" -ForegroundColor Yellow
Set-WindowsExplorerOptions -EnableShowFileExtensions -EnableShowFullPathInTitleBar -EnableShowRibbon

# Change Explorer home screen back to "This PC"
Write-Host "[+] Settings Explorer home screen back to This PC [+]" -ForegroundColor Yellow
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Type DWord -Value 1

# Better File Explorer
Write-Host "[+] Settings Better File Explorer [+]" -ForegroundColor Yellow
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1		
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1		
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

# Disable Xbox Gamebar
Write-Host "[+] Disabling Xbox Gamebar [+]" -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name AppCaptureEnabled -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name GameDVR_Enabled -Type DWord -Value 0

# Disable Web Search in Start Menu
	Write-Output "Disabling Bing Search in Start Menu..."
	If (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer")) {
		New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1

# Disable Wi-Fi Sense
	Write-Output "Disabling Wi-Fi Sense..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WiFISenseAllowed" -Type DWord -Value 0

# Disable Cortana
	Write-Output "Disabling Cortana..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Personalization\Settings")) {
		New-Item -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
	If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore")) {
		New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowCortana" -Name "Value" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" -Name "AllowInputPersonalization" -Type DWord -Value 0
	Get-AppxPackage "Microsoft.549981C3F5F10" | Remove-AppxPackage

# Disable Application suggestions and automatic installation
	Write-Output "Disabling Application suggestions..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-314559Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Name "AllowSuggestedAppsInWindowsInkWorkspace" -Type DWord -Value 0
	# Empty placeholder tile collection in registry cache and restart Start Menu process to reload the cache
	If ([System.Environment]::OSVersion.Version.Build -ge 17134) {
		$key = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.placeholdertilecollection\Current"
		Set-ItemProperty -Path $key.PSPath -Name "Data" -Type Binary -Value $key.Data[0..15]
		Stop-Process -Name "ShellExperienceHost" -Force -ErrorAction SilentlyContinue
	}

# Disable Activity History feed in Task View
	Write-Output "Disabling Activity History..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0

# Disable Feedback
	Write-Output "Disabling Feedback..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Siuf\Rules")) {
		New-Item -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null

# Disable Tailored Experiences
	Write-Output "Disabling Tailored Experiences..."
	If (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent")) {
		New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1

# Disable Advertising ID
	Write-Output "Disabling Advertising ID..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1

# Set UAC Level to High
	Write-Output "Raising UAC level..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 5
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 1

# Set Network to Public
	Write-Output "Setting current network profile to public..."
	Set-NetConnectionProfile -NetworkCategory Public

# Disable Autoplay
	Write-Output "Disabling Autoplay..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1

# Disable Autorun for all drives
	Write-Output "Disabling Autorun for all drives..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255

# Uninstall default third party applications
	Write-Output "Uninstalling default third party applications..."
	Get-AppxPackage "2414FC7A.Viber" | Remove-AppxPackage
	Get-AppxPackage "41038Axilesoft.ACGMediaPlayer" | Remove-AppxPackage
	Get-AppxPackage "46928bounde.EclipseManager" | Remove-AppxPackage
	Get-AppxPackage "4DF9E0F8.Netflix" | Remove-AppxPackage
	Get-AppxPackage "64885BlueEdge.OneCalendar" | Remove-AppxPackage
	Get-AppxPackage "7EE7776C.LinkedInforWindows" | Remove-AppxPackage
	Get-AppxPackage "828B5831.HiddenCityMysteryofShadows" | Remove-AppxPackage
	Get-AppxPackage "89006A2E.AutodeskSketchBook" | Remove-AppxPackage
	Get-AppxPackage "9E2F88E3.Twitter" | Remove-AppxPackage
	Get-AppxPackage "A278AB0D.DisneyMagicKingdoms" | Remove-AppxPackage
	Get-AppxPackage "A278AB0D.DragonManiaLegends" | Remove-AppxPackage
	Get-AppxPackage "A278AB0D.MarchofEmpires" | Remove-AppxPackage
	Get-AppxPackage "ActiproSoftwareLLC.562882FEEB491" | Remove-AppxPackage
	Get-AppxPackage "AD2F1837.GettingStartedwithWindows8" | Remove-AppxPackage
	Get-AppxPackage "AD2F1837.HPJumpStart" | Remove-AppxPackage
	Get-AppxPackage "AD2F1837.HPRegistration" | Remove-AppxPackage
	Get-AppxPackage "AdobeSystemsIncorporated.AdobePhotoshopExpress" | Remove-AppxPackage
	Get-AppxPackage "Amazon.com.Amazon" | Remove-AppxPackage
	Get-AppxPackage "C27EB4BA.DropboxOEM" | Remove-AppxPackage
	Get-AppxPackage "CAF9E577.Plex" | Remove-AppxPackage
	Get-AppxPackage "CyberLinkCorp.hs.PowerMediaPlayer14forHPConsumerPC" | Remove-AppxPackage
	Get-AppxPackage "D52A8D61.FarmVille2CountryEscape" | Remove-AppxPackage
	Get-AppxPackage "D5EA27B7.Duolingo-LearnLanguagesforFree" | Remove-AppxPackage
	Get-AppxPackage "DB6EA5DB.CyberLinkMediaSuiteEssentials" | Remove-AppxPackage
	Get-AppxPackage "DolbyLaboratories.DolbyAccess" | Remove-AppxPackage
	Get-AppxPackage "Drawboard.DrawboardPDF" | Remove-AppxPackage
	Get-AppxPackage "Facebook.Facebook" | Remove-AppxPackage
	Get-AppxPackage "Fitbit.FitbitCoach" | Remove-AppxPackage
	Get-AppxPackage "flaregamesGmbH.RoyalRevolt2" | Remove-AppxPackage
	Get-AppxPackage "GAMELOFTSA.Asphalt8Airborne" | Remove-AppxPackage
	Get-AppxPackage "KeeperSecurityInc.Keeper" | Remove-AppxPackage
	Get-AppxPackage "king.com.BubbleWitch3Saga" | Remove-AppxPackage
	Get-AppxPackage "king.com.CandyCrushFriends" | Remove-AppxPackage
	Get-AppxPackage "king.com.CandyCrushSaga" | Remove-AppxPackage
	Get-AppxPackage "king.com.CandyCrushSodaSaga" | Remove-AppxPackage
	Get-AppxPackage "king.com.FarmHeroesSaga" | Remove-AppxPackage
	Get-AppxPackage "Nordcurrent.CookingFever" | Remove-AppxPackage
	Get-AppxPackage "PandoraMediaInc.29680B314EFC2" | Remove-AppxPackage
	Get-AppxPackage "PricelinePartnerNetwork.Booking.comBigsavingsonhot" | Remove-AppxPackage
	Get-AppxPackage "SpotifyAB.SpotifyMusic" | Remove-AppxPackage
	Get-AppxPackage "ThumbmunkeysLtd.PhototasticCollage" | Remove-AppxPackage
	Get-AppxPackage "WinZipComputing.WinZipUniversal" | Remove-AppxPackage
	Get-AppxPackage "XINGAG.XING" | Remove-AppxPackage

# Disable Xbox features - Not applicable to Server
	Write-Output "Disabling Xbox features..."
	Get-AppxPackage "Microsoft.XboxApp" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.XboxIdentityProvider" | Remove-AppxPackage -ErrorAction SilentlyContinue
	Get-AppxPackage "Microsoft.XboxSpeechToTextOverlay" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.XboxGameOverlay" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.XboxGamingOverlay" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Xbox.TCUI" | Remove-AppxPackage
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0

# Removing Bloatware
Get-AppxPackage Microsoft.MixedReality.Portal | Remove-AppxPackage
Get-AppxPackage Microsoft.MicrosoftOfficeHub | Remove-AppxPackage
Get-AppxPackage Microsoft.Getstarted | Remove-AppxPackage

# Disable built-in Adobe Flash in IE and Edge
	Write-Output "Disabling built-in Adobe Flash in IE and Edge..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer" -Name "DisableFlashInIE" -Type DWord -Value 1
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons" -Name "FlashPlayerEnabled" -Type DWord -Value 0

# Uninstall Internet Explorer
	Write-Output "Uninstalling Internet Explorer..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -like "Internet-Explorer-Optional*" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Browser.InternetExplorer*" } | Remove-WindowsCapability -Online | Out-Null

# Remove Default Fax Printer
	Write-Output "Removing Default Fax Printer..."
	Remove-Printer -Name "Fax" -ErrorAction SilentlyContinue

# Uninstall Microsoft XPS Document Writer
	Write-Output "Uninstalling Microsoft XPS Document Writer..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Printing-XPSServices-Features" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null

# Unpin all Start Menu tiles
# Note: This function has no counterpart. You have to pin the tiles back manually.
Write-Output "Unpinning all Start Menu tiles..."
If ([System.Environment]::OSVersion.Version.Build -ge 15063 -And [System.Environment]::OSVersion.Version.Build -le 16299) {
	Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Include "*.group" -Recurse | ForEach-Object {
		$data = (Get-ItemProperty -Path "$($_.PsPath)\Current" -Name "Data").Data -Join ","
		$data = $data.Substring(0, $data.IndexOf(",0,202,30") + 9) + ",0,202,80,0,0"
		Set-ItemProperty -Path "$($_.PsPath)\Current" -Name "Data" -Type Binary -Value $data.Split(",")
	}
} ElseIf ([System.Environment]::OSVersion.Version.Build -ge 17134) {
	$key = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current"
	$data = $key.Data[0..25] + ([byte[]](202,50,0,226,44,1,1,0,0))
	Set-ItemProperty -Path $key.PSPath -Name "Data" -Type Binary -Value $data
	Stop-Process -Name "ShellExperienceHost" -Force -ErrorAction SilentlyContinue
}

# Unpin all Taskbar icons
Write-Output "Unpinning all Taskbar icons..."
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Name "Favorites" -Type Binary -Value ([byte[]](255))
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Name "FavoritesResolve" -ErrorAction SilentlyContinue
Stop-Process -ProcessName explorer

Write-Host " ____________________________________________________________________________ " -ForegroundColor Green 
Write-Host "|                                                                            |" -ForegroundColor Green
Write-Host "| [+]    Starting Application Installation | This will take a while!!    [+] |" -ForegroundColor Green
Write-Host "|____________________________________________________________________________|" -ForegroundColor Green 

Write-Host "[+] Installing Office Applications [+]" -ForegroundColor Yellow
choco install adobereader -y
choco install office365business -y
choco install evernote -y
choco install googledrive -y
choco install drawio -y

Write-Host "[+] Installing Communication Applications [+]" -ForegroundColor Yellow
choco install microsoft-teams.install -y
choco install skype -y
choco install slack -y
choco install discord -y

Write-Host "[+] Installing Web Browsers [+]" -ForegroundColor Yellow
choco install microsoft-edge -y
choco install googlechrome -y
choco install firefox -y
choco install opera -y

Write-Host "[+] Installing Cleaning and Antivirus Software [+]" -ForegroundColor Yellow
choco install ccleaner -y
choco install windirstat -y
choco install adwcleaner -y
choco install malwarebytes -y

Write-Host "[+] Installing Utilities [+]" -ForegroundColor Yellow
choco install crystaldiskinfo -y
choco install f.lux -y
choco install cpu-z.install -y
choco install speedfan -y
choco install samsung-magician -y
choco install powertoys -y
choco install 7zip.install -y
choco install winrar -y
choco install teracopy -y
choco install filezilla -y
choco install qbittorrent -y
choco install googleearthpro -y
choco install obs-studio -y
choco install handbrake.install -y
choco install intel-dsa -y
choco install audacity -y
choco install lessmsi -y
choco install greenshot -y
choco install intel-xtu -y

Write-Host "[+] Installing Networking Applications [+]" -ForegroundColor Yellow
choco install putty.install -y
choco install winscp.install -y
choco install wireshark -y
choco install advanced-ip-scanner -y
choco install burp-suite-free-edition -y
choco install openvpn -y
choco install glasswire -y
choco install nmap -y
choco install mysql.workbench -y

Write-Host "[+] Installing Design Software [+]" -ForegroundColor Yellow
choco install gimp -y
choco install inkscape -y
choco install lunacy -y
choco install blender -y
choco install sketchup -y

Write-Host "[+] Installing Scientific Software [+]" -ForegroundColor Yellow
choco install geogebra -y
choco install jmol -y

choco install yarn -y
choco install wget -y
choco install curl -y
choco install awscli -y
choco install azure-cli -y
choco install kubernetes-cli -y
choco install nodejs.install -y
choco install git.install -y
choco install openssh -y
choco install chirp.install -y
choco install spicetify-cli -y
choco install hp-ilo-cmdlets -y
choco install nuget.commandline -y

Write-Host "[+] Installing Media Software [+]" -ForegroundColor Yellow
choco install vlc -y
choco install itunes -y
choco install spotify -y

Write-Host "[+] Installing Dev Kits and Runtimes [+]" -ForegroundColor Yellow
choco install jdk8 -y
choco install jre8 -y

Write-Host "[+] Installing File and Booting Utilites [+]" -ForegroundColor Yellow
choco install rufus -y
choco install etcher -y
choco install win32diskimager.install -y
choco install imgburn -y
choco install poweriso -y

Write-Host "[+] Installing IDE Software [+]" -ForegroundColor Yellow
choco install visualstudio2019enterprise -y
choco install notepadplusplus.install -y
choco install vscode -y
choco install sublimetext3 -y
choco install vim -y
choco install neovim -y
choco install brackets -y
choco install atom -y
choco install emacs -y
choco install hxd -y
choco install arduino -y

Write-Host "[+] Installing Frameworks and Compilers [+]" -ForegroundColor Yellow
choco install python3 -y
choco install ruby -y
choco install golang -y
choco install dart-sdk -y
choco install r.project -y
choco install opencv -y
choco install deno -y
choco install mono -y
choco install flutter -y
choco install powerbi -y
choco install rust -y
choco install selenium -y
choco install selenium-gecko-driver -y
choco install selenium-chrome-driver -y
choco install codecov -y
choco install jenkins -y
choco install mingw -y
choco install cmake -y

Write-Host "[+] Installing Terminals [+]" -ForegroundColor Yellow
choco install hyper -y
choco install cygwin -y
choco install cmder -y
choco install microsoft-windows-terminal -y

Write-Host "[+] Installing Dev Tools [+]" -ForegroundColor Yellow
choco install sourcetree -y
choco install gitkraken -y
choco install github-desktop -y
choco install jetbrainstoolbox -y
choco install dotultimate -y
choco install snoop -y
choco install postman -y
choco install docker-desktop -y

Write-Host "[+] Installing VM [+]" -ForegroundColor Yellow
choco install vmwarevsphereclient -y
choco install vmwareworkstation -y
choco install virtualbox -y
choco install mremoteng -y

Write-Host "[+] Installing Game Services [+]" -ForegroundColor Yellow
choco install origin -y
choco install steam -y
choco install uplay -y

Write-Host "[+] Installing Dell and Driver Services [+]" -ForegroundColor Yellow
choco install nvidia-display-driver -y
choco install geforce-experience -y
choco install dellcommandupdate -y

scoop bucket add scoop-bucket https://github.com/Rigellute/scoop-bucket
scoop install spotify-tui

Set-Location $Home\Pictures\Wallpapers
git clone https://github.com/morpheusthewhite/spicetify-themes.git
Set-Location spicetify-themes
Copy-Item -r * ~/.config/spicetify/Themes
spicetify config current_theme Lovelace

Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
# Start the default settings
Set-Prompt
# Alternatively set the desired theme:
Set-Theme Operator
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
Start-Process https://github.com/JanDeDobbeleer/oh-my-posh

Start-Process https://download01.logi.com/web/ftp/pub/techsupport/gaming/lghub_installer.exe
Start-Process https://3dprinter.sindoh.com/en/file/download/?fileNm=1599524415224__3DWOX_Desktop_v1_5_2751_1_setup.zip
Start-Process https://zpl.io/download-windows-64
Start-Process https://downloads.surfshark.com/windows/latest/SurfsharkSetup.exe
Start-Process https://d3l8qviayb6xr0.cloudfront.net/Boom3Dwin/webstore/Boom3D.msi
Start-Process https://download.tidal.com/desktop/TIDALSetup.exe
Start-Process https://www.microsoft.com/en-au/microsoft-365/visio/flowchart-software
Start-Process https://www.microsoft.com/en-au/microsoft-365/project/project-management-software
Start-Process https://www.microsoft.com/en-au/p/soundcloud-for-windows-beta/9nvjbt29b36l?activetab=pivot:overviewtab
Start-Process https://www.netacad.com/portal/resources/file/f89cbfc4-878c-40bc-8ba8-f1acc24957ec
Start-Process https://repo.anaconda.com/archive/Anaconda3-2020.07-Windows-x86_64.exe
Start-Process https://download.bleepingcomputer.com/dl/5f7c927722e9f8d5f69f2a0cdbd94b2a/5fb0791e/windows/security/security-utilities/r/rkill/rkill.exe
Start-Process https://nucleo-app-releases.s3-accelerate.amazonaws.com/windows/Nucleo_2.6.2.exe
Start-Process https://www.qt.io/download-thank-you?hsLang=en
Start-Process https://www.autodesk.com.au/
Start-Process https://www.hitmanpro.com/en-us/hmp.aspx
Start-Process https://au.mathworks.com/campaigns/products/trials.html?prodcode=ML
Start-Process https://alpha.kite.com/release/dls/windows/current
Start-Process https://www.adobe.com/au/creativecloud.html
Start-Process https://github.com/alacritty/alacritty/releases
Start-Process https://github.com/microsoft/winget-cli/releases/tag/v0.2.2941
Start-Process https://www.dell.com/support/home/en-au/product-support/product/alienware-15-laptop/drivers

$Path = "$Home\Pictures\Wallpapers"
mkdir $Path
$images = 'https://i.redd.it/9cv77eoemqa41.png', 'https://i.redd.it/587a3w75p1b51.png', 'https://i.redd.it/bygxp2mhilu51.png', 'https://i.redd.it/cm2l9qq30yz41.png', 'https://i.redd.it/rhu9xgqq9i351.jpg', 'https://external-preview.redd.it/Uob7gkJ1sywmNGCSwGL6oG0mPDwZ-v7_6rR05IBU2cg.jpg?auto=webp&s=f26a972503bbf8355b54d2d603a93d16fc226100', 'https://i.redd.it/mhqluosrksw41.png', 'https://i.redd.it/nvsf29d135051.jpg', 'https://i.redd.it/wi4icfbynhd51.png', 'https://preview.redd.it/teq4suulbvf51.png?width=3440&format=png&auto=webp&s=1c251bc8f84358efd40fedb0a30e98b8c024fab7', 'https://i.redd.it/3o0hkjal8j151.jpg', 'https://i.redd.it/3iwpgz1c9hh41.jpg', 'https://i.redd.it/btqplv4tonv31.png', 'https://i.redd.it/tizoc0t311c51.png', 'https://i.redd.it/qqjhrf0io4c51.png', 'https://i.redd.it/3w67b1kx82z21.png', 'https://i.redd.it/ycn03d7ildi51.png', 'https://i.redd.it/4digo73rwu251.png'
$Path = "$Home\Pictures\Wallpapers\"

git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_basic_vimrc.sh

function DownloadFile([Object[]] $sourceFiles,[string]$targetDirectory) {
 $wc = New-Object System.Net.WebClient

 foreach ($sourceFile in $sourceFiles){
  $sourceFileName = $sourceFile.SubString($sourceFile.LastIndexOf('/')+1)
  $targetFileName = $targetDirectory + $sourceFileName
  $wc.DownloadFile($sourceFile, $targetFileName)      
  Write-Host "Downloaded $sourceFile to file location $targetFileName"
 }
}
DownloadFile $images $Path

# Rename the computer
Write-Host "[+] Renaming host to 'ChangeMe'" -ForegroundColor Green
(Get-WmiObject win32_computersystem).rename("Kizio-WS") | Out-Null
Write-Host "`t[-] Change will take effect after a restart" -ForegroundColor Yellow

Write-Output "`n The installation was a success. Press any key to restart!"
[Console]::ReadKey($true) | Out-Null

# Restart computer
Write-Output "Restarting..."
Restart-Computer
