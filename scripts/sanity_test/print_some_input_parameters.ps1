# input $Name (required) and $UpperCase (optional with default value of $false)
# $UpperCase is a switch, so it can be used as -UpperCase or -UpperCase:$true
param(
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [switch]$UpperCase
)

Write-Host "INFO: Running print_some_input_parameters.ps1"

Write-Verbose "VERBOSE: Checking input parameters: Name=$Name, UpperCase=$UpperCase"
# Check if $Name is null or an empty string
if ([string]::IsNullOrEmpty($Name)) {
    throw "Must pass in -Name parameter"
}

# if $UpperCase is $true, convert $Name to upper case
if ($UpperCase) {
    $Name = $Name.ToUpper()
}

# print the input parameters
Write-Host "INFO: Name: $Name"
Write-Host "INFO: UpperCase: $UpperCase"

# print out the output of 
Write-Host "INFO: Get-Module -ListAvailable PowerShellGet"
Get-Module -ListAvailable PowerShellGet

# print out the PSModulePath
Write-Host 'PSModulePath: $env:PSModulePath'
$env:PSModulePath -split ';'
