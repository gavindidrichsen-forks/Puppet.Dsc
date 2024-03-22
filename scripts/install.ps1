[cmdletbinding()]
Param(
  [switch]$Full
)

Write-Host 'Installing Puppet DSC dependencies'
$ErrorActionPreference = 'Stop'

$PowerShellModules = @(
  @{ Name = 'PSFramework' }
  @{ Name = 'powershell-yaml' }
  @{ Name = 'PSScriptAnalyzer' }
  @{ Name = 'xPSDesiredStateConfiguration' }
  @{ Name = 'PSDscResources' }
  @{ Name = 'PowerShellGet'}
  @{ Name = 'Pester'}
)

If ($Full) {
  $ChocolateyPackages += 'pdk'
  $PuppetInstalled = Get-Command puppet -ErrorAction SilentlyContinue
  If ($null -eq $PuppetInstalled) {
    $ChocolateyPackages += 'puppet-agent'
  }
}

# REMOVING THIS INTO ANOTHER SCRIPT
# If ($Full -or $ENV:CI -eq 'True') {
#   Write-Host 'Ensuring WinRM is configured for DSC'
  # ./winrm/setup_winrm.ps1
  # Get-ChildItem WSMan:\localhost\Listener\ -OutVariable Listeners | Format-List * -Force
  # $HTTPListener = $Listeners | Where-Object -FilterScript { $_.Keys.Contains('Transport=HTTP') }
  # If ($HTTPListener.Count -eq 0) {
  #   winrm create winrm/config/Listener?Address=*+Transport=HTTP
  #   winrm e winrm/config/listener
  # }
# }


Write-Host "Installing the following chocolately packages [$ChocolateyPackages] with choco unless already present"
foreach ($package in $ChocolateyPackages) {
  # check if the $package is in choco's list of installed packages
  $installed = choco list | ForEach-Object { ($_ -split ' ')[0] } | Select-String -Pattern "^$package$"
  if (-not $installed) {
    Write-Host "Installing '$package' with choco"
    $output = choco install $package --yes --no-progress --stop-on-first-failure --ignore-checksums
    if ($LastExitCode -ne 0) {
      throw "Installation with choco failed for package $package.  Output: `n$output"
    }
  } else {
    Write-Host "'$package' already installed."
  }
}

Write-Host 'Reloading Path to pick up installed software'
Import-Module C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1
Update-SessionEnvironment

# Check if the PowerShellGet module is installed
if (!(Get-Module -ListAvailable -Name PowerShellGet)) {
  # If the module is not installed, install it
  Write-Host "Installing PowerShellGet module..."
  Install-Module PowerShellGet -Force
} else {
  Write-Host "PowerShellGet module already installed."
}

Write-Host "######## PSVersion,ExecutionPolicy,USERPROFILE, whoami"
$PSVersionTable.PSVersion
Get-ExecutionPolicy
$env:USERPROFILE
whoami
Write-Host "######## Available Modules"
Get-Module -ListAvailable
exit 0

Import-Module PowerShellGet -ErrorAction Stop
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Write-Host "Installing $($PowerShellModules.Count) modules with Install-Module"
exit 0
ForEach ($Module in $PowerShellModules) {
$InstalledModuleVersions = Get-Module -ListAvailable $Module.Name -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Version
If ($Module.ContainsKey('RequiredVersion')) {
  $AlreadyInstalled = $null -ne ($InstalledModuleVersions | Where-Object -FilterScript { $_ -eq $Module.RequiredVersion })
} Else {
  $AlreadyInstalled = $null -ne $InstalledModuleVersions
}
If ($AlreadyInstalled) {
  Write-Host "$($Module.Name) module already installed at $($InstalledModuleVersions)"
} Else {
  Write-Host "Installing $($Module.Name) module..."
  try {
    Install-Module @Module -SkipPublisherCheck -AllowClobber
  } catch {
    Write-Host "Failed to install $($Module.Name) module, retrying with -Force"
    Install-Module @Module -Force -SkipPublisherCheck -AllowClobber
  }
}
}