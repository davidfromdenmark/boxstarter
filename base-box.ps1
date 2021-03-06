$coreApps = @(
    'chocolatey'
    ,'vlc'
    ,'jdk8'
    ,'adobereader-update'
    ,'googlechrome'
    ,'opera'
    ,'adblockpluschrome'
    ,'lastpass'
    ,'itunes'
    ,'dropbox'
    ,'youtube-dl'
    ,'googledrive'
    ,'icloud'

)

$devApps = @(
        'fiddler'
        ,'docker-for-windows'
        ,'wsl'
        ,'sysinternals'
        ,'microsoft-teams'
        ,'vim'
        ,'nmap'
        ,'nuget.commandline'
        ,'nugetpackageexplorer'
        ,'beyondcompare'
        ,'visualstudiocode'
        ,'nodejs.install'
        ,'ilspy'
        ,'7zip.install'
        ,'beyondcompare'
        ,'postman'
        ,'git.install'
        ,'github'
        ,'sourcetree'
        ,'sysinternals'
        ,'sourcetree'
        ,'sql-server-2017'
        ,'sql-server-management-studio'
        
        # dotnet specific

        ,'dotnet3.5'
        ,'dotnet4.5'
        ,'dotnet4.6.2'
        ,'dotnet4.7.1'
        ,'dotnetcore-sdk'

        # visual studio
        ,'visualstudio2017professional'
        ,'visualstudio2017-workload-azure'
        ,'visualstudio2017-workload-netcoretools'
        ,'visualstudio2017-workload-webbuildtools'
        ,'visualstudio2017-workload-netweb'
        ,'visualstudio2017-workload-node'
        ,'visualstudio2017-workload-webcrossplat'
        ,'resharper'
        ,'resharper-platform'
        ,'visualstudio2017buildtools'
    )






function executeScript {
    Param ([string]$script)
    $finalBaseHelperUri = "https://raw.githubusercontent.com/davidfromdenmark/boxstarter/master/scripts"
    write-host "executing $finalBaseHelperUri/$script ..."
	Invoke-Expression ((new-object net.webclient).DownloadString("$finalBaseHelperUri/$script"))
}

function InstallChocoApps($packageArray){

    foreach ($package in $packageArray) {
        &choco install $package --limitoutput
    }

}

function SetRegionalSettings(){
    &"$env:windir\system32\tzutil.exe" /s "South Africa Standard Time"
    
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortDate     -Value dd-MMM-yy
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sCountry       -Value "South Africa"
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortTime     -Value HH:mm
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sTimeFormat    -Value HH:mm:ss
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sLanguage      -Value ENZA
}

function InstallWindowsUpdate()
{
    Enable-MicrosoftUpdate
    Install-WindowsUpdate -AcceptEula
    if (Test-PendingReboot) { Invoke-Reboot }
}




function InstallWindowsFeatures()
{
    $windowsFeatures = @(
        'Windows-Identity-Foundation'
        ,'Microsoft-Hyper-V-All'
        ,'Microsoft-Windows-Subsystem-Linux'
        ,'IIS-WebServerRole'
        ,'IIS-WebServer'
        ,'IIS-CommonHttpFeatures'
        ,'IIS-HttpErrors'
        ,'IIS-HttpRedirect'
        ,'IIS-ApplicationDevelopment'
        ,'IIS-NetFxExtensibility45'
        ,'IIS-HealthAndDiagnostics'
        ,'IIS-HttpLogging'
        ,'IIS-LoggingLibraries'
        ,'IIS-RequestMonitor'
        ,'IIS-HttpTracing'
        ,'IIS-Security'
        ,'IIS-URLAuthorization'
        ,'IIS-RequestFiltering'
        ,'IIS-Performance'
        ,'IIS-HttpCompressionDynamic'
        ,'IIS-WebServerManagementTools'
        ,'IIS-ManagementScriptingTools'
        ,'IIS-HostableWebCore'
        ,'IIS-StaticContent'
        ,'IIS-DefaultDocument'
        ,'IIS-WebSockets'
        ,'IIS-ASPNET'
        ,'IIS-ServerSideIncludes'
        ,'IIS-CustomLogging'
        ,'IIS-BasicAuthentication'
        ,'IIS-HttpCompressionStatic'
        ,'IIS-ManagementConsole'
        ,'IIS-ManagementService'
        ,'IIS-WMICompatibility'
        ,'IIS-CertProvider'
        ,'IIS-WindowsAuthentication'
        ,'IIS-DigestAuthentication'
    )
    
    foreach ($package in $windowsFeatures) {
        &choco install $package --source windowsfeatures
    }
}



function CleanDesktopShortcuts()
{
    Write-Host "Cleaning desktop of shortcuts"
    $allUsersDesktop = "C:\Users\Public\Desktop"
    Get-ChildItem -Path $allUsersDesktop\*.lnk -Exclude *BoxStarter* | remove-item
}

function PinToTaskBar()
{
    # pin apps that update themselves
    choco pin add -n=googlechrome
    choco pin add -n=sourcetree
}

# -------------START--------------
$Boxstarter.RebootOk=$true
$Boxstarter.NoPassword=$false
$Boxstarter.AutoLogin=$true

Write-BoxstarterMessage "-------------START--------------"
SetRegionalSettings
Write-BoxstarterMessage "Windows update..."
# InstallWindowsUpdate
choco feature enable --name=allowGlobalConfirmation


#--- Setting up Windows ---
executeScript "SystemConfiguration.ps1";
executeScript "FileExplorerSettings.ps1";
executeScript "RemoveDefaultApps.ps1";

Write-BoxstarterMessage "Starting chocolatey installs"
InstallWindowsFeatures

InstallChocoApps $coreApps
InstallChocoApps $devApps

CleanDesktopShortcuts
PinToTaskBar


