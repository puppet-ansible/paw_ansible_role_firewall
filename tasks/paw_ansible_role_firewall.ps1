# Puppet task for executing Ansible role: ansible_role_firewall
# This script runs the entire role via ansible-playbook

$ErrorActionPreference = 'Stop'

# Determine the ansible modules directory
if ($env:PT__installdir) {
  $AnsibleDir = Join-Path $env:PT__installdir "lib\puppet_x\ansible_modules\ansible_role_firewall"
} else {
  # Fallback to Puppet cache directory
  $AnsibleDir = "C:\ProgramData\PuppetLabs\puppet\cache\lib\puppet_x\ansible_modules\ansible_role_firewall"
}

# Check if ansible-playbook is available
$AnsiblePlaybook = Get-Command ansible-playbook -ErrorAction SilentlyContinue
if (-not $AnsiblePlaybook) {
  $result = @{
    _error = @{
      msg = "ansible-playbook command not found. Please install Ansible."
      kind = "puppet-ansible-converter/ansible-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Check if the role directory exists
if (-not (Test-Path $AnsibleDir)) {
  $result = @{
    _error = @{
      msg = "Ansible role directory not found: $AnsibleDir"
      kind = "puppet-ansible-converter/role-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Detect playbook location (collection vs standalone)
# Collections: ansible_modules/collection_name/roles/role_name/playbook.yml
# Standalone: ansible_modules/role_name/playbook.yml
$CollectionPlaybook = Join-Path $AnsibleDir "roles\paw_ansible_role_firewall\playbook.yml"
$StandalonePlaybook = Join-Path $AnsibleDir "playbook.yml"

if ((Test-Path (Join-Path $AnsibleDir "roles")) -and (Test-Path $CollectionPlaybook)) {
  # Collection structure
  $PlaybookPath = $CollectionPlaybook
  $PlaybookDir = Join-Path $AnsibleDir "roles\paw_ansible_role_firewall"
} elseif (Test-Path $StandalonePlaybook) {
  # Standalone role structure
  $PlaybookPath = $StandalonePlaybook
  $PlaybookDir = $AnsibleDir
} else {
  $result = @{
    _error = @{
      msg = "playbook.yml not found in $AnsibleDir or $AnsibleDir\roles\paw_ansible_role_firewall"
      kind = "puppet-ansible-converter/playbook-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Build extra-vars from PT_* environment variables
$ExtraVars = @{}
if ($env:PT_port) {
  $ExtraVars['port'] = $env:PT_port
}
if ($env:PT_rule) {
  $ExtraVars['rule'] = $env:PT_rule
}
if ($env:PT_firewall_state) {
  $ExtraVars['firewall_state'] = $env:PT_firewall_state
}
if ($env:PT_firewall_enabled_at_boot) {
  $ExtraVars['firewall_enabled_at_boot'] = $env:PT_firewall_enabled_at_boot
}
if ($env:PT_firewall_flush_rules_and_chains) {
  $ExtraVars['firewall_flush_rules_and_chains'] = $env:PT_firewall_flush_rules_and_chains
}
if ($env:PT_firewall_template) {
  $ExtraVars['firewall_template'] = $env:PT_firewall_template
}
if ($env:PT_firewall_allowed_tcp_ports) {
  $ExtraVars['firewall_allowed_tcp_ports'] = $env:PT_firewall_allowed_tcp_ports
}
if ($env:PT_firewall_allowed_udp_ports) {
  $ExtraVars['firewall_allowed_udp_ports'] = $env:PT_firewall_allowed_udp_ports
}
if ($env:PT_firewall_forwarded_tcp_ports) {
  $ExtraVars['firewall_forwarded_tcp_ports'] = $env:PT_firewall_forwarded_tcp_ports
}
if ($env:PT_firewall_forwarded_udp_ports) {
  $ExtraVars['firewall_forwarded_udp_ports'] = $env:PT_firewall_forwarded_udp_ports
}
if ($env:PT_firewall_additional_rules) {
  $ExtraVars['firewall_additional_rules'] = $env:PT_firewall_additional_rules
}
if ($env:PT_firewall_enable_ipv6) {
  $ExtraVars['firewall_enable_ipv6'] = $env:PT_firewall_enable_ipv6
}
if ($env:PT_firewall_ip6_additional_rules) {
  $ExtraVars['firewall_ip6_additional_rules'] = $env:PT_firewall_ip6_additional_rules
}
if ($env:PT_firewall_log_dropped_packets) {
  $ExtraVars['firewall_log_dropped_packets'] = $env:PT_firewall_log_dropped_packets
}
if ($env:PT_firewall_disable_firewalld) {
  $ExtraVars['firewall_disable_firewalld'] = $env:PT_firewall_disable_firewalld
}
if ($env:PT_firewall_disable_ufw) {
  $ExtraVars['firewall_disable_ufw'] = $env:PT_firewall_disable_ufw
}

$ExtraVarsJson = $ExtraVars | ConvertTo-Json -Compress

# Execute ansible-playbook with the role
Push-Location $PlaybookDir
try {
  ansible-playbook playbook.yml `
    --extra-vars $ExtraVarsJson `
    --connection=local `
    --inventory=localhost, `
    2>&1 | Write-Output
  
  $ExitCode = $LASTEXITCODE
  
  if ($ExitCode -eq 0) {
    $result = @{
      status = "success"
      role = "ansible_role_firewall"
    }
  } else {
    $result = @{
      status = "failed"
      role = "ansible_role_firewall"
      exit_code = $ExitCode
    }
  }
  
  Write-Output ($result | ConvertTo-Json)
  exit $ExitCode
}
finally {
  Pop-Location
}
