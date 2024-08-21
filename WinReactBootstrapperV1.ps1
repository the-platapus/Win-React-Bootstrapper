if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# NOTE:
# Chocolatey is not a Node.js package manager.
# Please ensure it is already installed on your system.

# setting execution policy and installing chocolatay package manager
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# download and install Node.js
choco install -y nodejs-lts microsoft-openjdk17

# verifies the right Node.js version is in the environment
node -v # should print the installed version

# verifies the right npm version is in the environment
npm -v # should print the installed version

# download and install yarn
npm install --global yarn

# download and install winget
$progressPreference = 'silentlyContinue'
$latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object {$_.EndsWith(".msixbundle")}
$latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
Write-Information "Downloading winget to artifacts directory..."
Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage $latestWingetMsixBundle
Add-AppXPackage -Path .\MicrosoftDesktopAppInstaller_8wekyb3d8bbwe.msixbundle

# download and install android studio
winget install -e --id Google.AndroidStudio

#***************************************************************************************#
#***************************************************************************************#
#                                                                                       #
#                       Portable Android SDK Environment Setup                          #
#                                 Powershell Script                                     #
#                                                                                       #
#                                   By: sh7411usa                                       #
#                                                                                       #
#                      For Use With Portable Drive Installation                         #
#                                                                                       #
#                                                                                       #
#***************************************************************************************#
#***************************************************************************************#

#Configure Execution Policy
Set-ExecutionPolicy Bypass -Scope Process -Force

#Display Welcome to User
Write-Output ""
Write-Output "**************************************************************************"
Write-Output "**************************************************************************"
Write-Output "**                                                                      **"
Write-Output "**                                                                      **"
Write-Output "**                    Android SDK Environment Setup                     **"
Write-Output "**                                                                      **"
Write-Output "**                                                                      **"
Write-Output "**************************************************************************"
Write-Output "**************************************************************************"
Write-Output `n

#Advise of Execution Policy
$outStr = (get-ExecutionPolicy) | Out-String
Write-Host -NoNewline "Checking Execution Policy... "
Write-Host $outStr

#Set Working Directory (containing path to Android SDK installation):
$BpathTo = (Get-Item -Path ".\").FullName

#Update for User Specific data, (usually found under "C:\Users\User\"):
#ANDROID_SDK_HOME
#ANDROID_EMULATOR_HOME
#ANDROID_AVD_HOME 
$pathTo = "$BpathTo\User"
Write-Host -NoNewline "Setting ANDROID_SDK_HOME to:      $pathTo"
[Environment]::SetEnvironmentVariable("ANDROID_SDK_HOME", $pathTo, "Machine")
Write-Output "              ...Done"
$pathTo+="\.android"
Write-Host -NoNewline "Setting ANDROID_EMULATOR_HOME to: $pathTo"
[Environment]::SetEnvironmentVariable("ANDROID_EMULATOR_HOME", $pathTo, "Machine")
Write-Output "     ...Done"
$pathTo+="\avd"
Write-Host -NoNewline "Setting ANDROID_AVD_HOME to:      $pathTo"
[Environment]::SetEnvironmentVariable("ANDROID_AVD_HOME", $pathTo, "Machine")
Write-Output " ...Done"
#Create/Update ANDOID_HOME environmental variable:
### The Program data, usually found under "C:\Program Files (x86)\Android Studio\"
$pathTo = "$BpathTo\SDK"
Write-Host -NoNewline "Setting ANDROID_SDK_ROOT to:      $pathTo"
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $pathTo, "Machine")
Write-Output "               ...Done"
Write-Host -NoNewline "Setting ANDROID_HOME to:          $pathTo"
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $pathTo, "Machine")
Write-Output "               ...Done
"
Write-Output "Keep up to date on Android Studio's environmental variables:
https://developer.android.com/studio/command-line/variables
"

#Update PATH environmental variable:
Write-Output "Updating PATH:"
$pathTo = "$BpathTo\SDK"
$new1="$pathTo"+"\tools;"
$new2="$pathTo"+"\tools\bin;"
$new3="$pathTo"+"\platform-tools;"
$newPath=";"+$new1+$new2+$new3
Write-Output "Adding: $new1"
Write-Output "Adding: $new2"
Write-Output "Adding: $new3"
$new4="$BpathTo"+"\User;"
Write-Output "Adding: $new4"
$newPath+=$new4
$env:Path+=$newPath
Write-Output ""
Write-Output "Done... Environment Setup Has Finished."
Write-Output ""

#Install Chocolatey and choco packages:
$InstallChoco = $False
##TODO:##if (Get-Command choco.exe -ErrorAction SilentlyContinue) {$InstallChoco = $true} #tests if choco.exe exists
If(Test-Path -Path "$env:ProgramData\Chocolatey") {} Else {$InstallChoco=$true} #tests if choco exists in $env:
if ($InstallChoco){ #Installs choco if not already installed
    Write-Output "Installing 'Chocolatey Installer'"
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    Write-Output `n}
$Packages = 'ADB', 'NotepadPlusPlus' #<-- Add packages here
ForEach ($PackageName in $Packages){ #installs choco packages listed above, one by one.
    Write-Output "Attempting Chocolatey Install: $PackageName"
    choco install --force $PackageName -y 
    Write-Output `n}

$BpathTo = (Get-Item -Path ".\").FullName
$pathTo = "$BpathTo\android-studio\bin\idea.properties"
$newCont="
idea.config.path=$BpathTo/User/.AndroidStudio/config
idea.system.path=$BpathTo/User/.AndroidStudio/system
idea.max.intellisense.filesize=2500
idea.max.content.load.filesize=20000
idea.cycle.buffer.size=1024
idea.no.launcher=false
idea.dynamic.classpath=false
idea.popup.weight=heavy
sun.java2d.d3d=false
swing.bufferPerWindow=true
sun.java2d.pmoffscreen=false
sun.java2d.uiScale.enabled=true
javax.swing.rebaseCssSizeMap=true
idea.xdebug.key=-Xdebug
idea.fatal.error.notification=disabled
"
Clear-Content $pathTo
Set-Content $pathTo $newCont

#Launch the Studio:
$pathTo = "$BpathTo\android-studio\bin\studio64.exe"
Write-Output "Starting Process: ANDROID STUDIO (x64)"
Write-Output "Initiating @ $pathTo"
Start-Process $pathTo
Write-Output `n

#Startup the Emulator:
##TODO:##See above link regarding setting emulator variables.
##First, update the emulator's *.ini to match the current directory:
$avdPath="$BpathTo\User\.android\avd\Nexus_x86.ini"
Write-Host -NoNewline "Updating Emulator: $avdPath..."
if (Test-Path $avdPath){Remove-Item $avdPath}
New-Item $avdPath | Out-Null
Clear-Content $avdPath
Set-Content $avdPath "avd.ini.encoding=UTF-8
path=$BpathTo\User\.android\avd\Nexus_x86.avd
path.rel=avd\Nexus_x86.avd
target=android-24"
Write-Output "Done"

##Second, Launch the emulator:
Write-Output "Launching: 'Nexus_x86' Emulator..."
$arg="-avd Nexus_x86"
$pathTo = "$Bpathto\localInstall\emulator\emulator.exe"
SDK\emulator\emulator.exe -avd Nexus_x86
Write-Output `n

# Function to display the menu and get user choice
function Show-Menu {
    param (
        [string]$Title = 'Select an option',
        [string[]]$Options = @()
    )

    $optionsCount = $Options.Length
    if ($optionsCount -eq 0) {
        Write-Host "No options provided." -ForegroundColor Red
        return $null
    }

    Write-Host "$Title`n" -ForegroundColor Green

    for ($i = 0; $i -lt $optionsCount; $i++) {
        Write-Host "$($i + 1). $($Options[$i])"
    }

    $choice = Read-Host "Enter the number of your choice"
    $choice = [int]$choice - 1

    if ($choice -ge 0 -and $choice -lt $optionsCount) {
        return $choice
    } else {
        Write-Host "Invalid choice. Please enter a number between 1 and $optionsCount." -ForegroundColor Red
        return $null
    }
}

# Define your options
$options = @(
    'Option 1: Download and Install React-native',
    'Option 2: Download and Install Expo'
)

# Show menu and get user choice
$choice = Show-Menu -Title 'Choose an Option' -Options $options

# Execute action based on user choice
switch ($choice) {
    0 {
        npm install -g create-react-native-app
        npm uninstall -g react-native-cli @react-native-community/cli
        npx @react-native-community/cli@latest init AwesomeProject
    }
    1 {
        npx create-expo-app@latest
    }
    default {
        Write-Host "No valid option selected." -ForegroundColor Red
    }
}

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');