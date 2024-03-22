# configure WinRM with default settings (outputs message if winrm is already configured)
winrm quickconfig -quiet

# set the WinRM firewall rules
$rules = Get-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)" -ErrorAction SilentlyContinue
if ($null -eq $rules) {
    Write-Host "Firewall rule for WinRM does not exist."
} else {
    foreach ($rule in $rules) {
        # DEBUG: Display detailed information about the rule
        # $rule | Format-List *

        # Get the address filter for the firewall rule
        $filter = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $rule

        # DEBUG: Display detailed information about the address filter
        # $filter | Format-List *

        if ($filter.RemoteAddress -eq 'Any') {
            Write-Host "Firewall rule '$($rule.Name)' is already configured for WinRM."
        } else {
            Write-Host "configuring the firewall rule '$($rule.Name)' for WinRM"
            Set-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)" -RemoteAddress Any
        }
    }
}

# configure WinRM to allow unencrypted connections and basic authentication
if ((winrm get winrm/config/service) -match "AllowUnencrypted = true") {
    Write-Host "WinRM is already configured to allow unencrypted connections."
} else {
    Write-Host "configuring WinRM to allow unencrypted connections."
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
}

if ((winrm get winrm/config/service/auth) -match "Basic = true") {
    Write-Host "WinRM is already configured to allow basic authentication."
} else {
    Write-Host "configuring WinRM to allow basic authentication."
    winrm set winrm/config/service/auth '@{Basic="true"}'
}
