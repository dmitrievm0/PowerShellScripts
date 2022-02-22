$LocalAVDpath            = "c:\temp\avd\"
$WVDBootURI              = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH'
$WVDAgentURI             = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv'
$FSLogixURI              = 'https://aka.ms/fslogix_download'
$FSInstaller             = 'FSLogixAppsSetup.zip'

Install-Module -Name PowerShellGet -Force

#    Test/Create Temp Directory    #
####################################
New-Item -Path c:\ -Name New-AVDSessionHost.log -ItemType File
Add-Content `
-LiteralPath C:\New-AVDSessionHost.log `
"
ProfilePath       = $ProfilePath
"

if((Test-Path c:\temp) -eq $false) {
    Add-Content -LiteralPath C:\New-AVDSessionHost.log "Create C:\temp Directory"
    Write-Host `
        -ForegroundColor Cyan `
        -BackgroundColor Black `
        "creating temp directory"
    New-Item -Path c:\temp -ItemType Directory
}
else {
    Add-Content -LiteralPath C:\New-AVDSessionHost.log "C:\temp Already Exists"
    Write-Host `
        -ForegroundColor Yellow `
        -BackgroundColor Black `
        "temp directory already exists"
}
if((Test-Path $LocalAVDpath) -eq $false) {
    Add-Content -LiteralPath C:\New-AVDSessionHost.log "Create C:\temp\AVD Directory"
    Write-Host `
        -ForegroundColor Cyan `
        -BackgroundColor Black `
        "creating c:\temp\wvd directory"
    New-Item -Path $LocalAVDpath -ItemType Directory
}
else {
    Add-Content -LiteralPath C:\New-AVDSessionHost.log "C:\temp\AVD Already Exists"
    Write-Host `
        -ForegroundColor Yellow `
        -BackgroundColor Black `
        "c:\temp\avd directory already exists"
}



#    Download FSLogix    
##########################

Add-Content -LiteralPath C:\New-AVDSessionHost.log "Downloading FSLogix"
Invoke-WebRequest -Uri $FSLogixURI -OutFile "$LocalAVDpath$FSInstaller"


#    Prep for WVD Install    #
##############################
Add-Content -LiteralPath C:\New-AVDSessionHost.log "Unzip FSLogix"
Expand-Archive `
    -LiteralPath "$LocalAVDpath\$FSInstaller" `
    -DestinationPath "$LocalAVDpath\FSLogix" `
    -Force `
    -Verbose
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
cd $LocalAVDpath 
Add-Content -LiteralPath C:\New-AVDSessionHost.log "UnZip FXLogix Complete"


#    FSLogix Install    #
#########################
Add-Content -LiteralPath C:\New-AVDSessionHost.log "Installing FSLogix"
$fslogix_deploy_status = Start-Process `
    -FilePath "$LocalAVDpath\FSLogix\x64\Release\FSLogixAppsSetup.exe" `
    -ArgumentList "/install /quiet" `
    -Wait `
    -Passthru