# paw_ansible_role_firewall
# @summary Manage paw_ansible_role_firewall configuration
#
# @param port
# @param rule
# @param firewall_state
# @param firewall_enabled_at_boot
# @param firewall_flush_rules_and_chains
# @param firewall_template
# @param firewall_allowed_tcp_ports
# @param firewall_allowed_udp_ports
# @param firewall_forwarded_tcp_ports
# @param firewall_forwarded_udp_ports
# @param firewall_additional_rules
# @param firewall_enable_ipv6
# @param firewall_ip6_additional_rules
# @param firewall_log_dropped_packets
# @param firewall_disable_firewalld Set to true to ensure other firewall management software is disabled.
# @param firewall_disable_ufw
# @param par_vardir Base directory for Puppet agent cache (uses lookup('paw::par_vardir') for common config)
# @param par_tags An array of Ansible tags to execute (optional)
# @param par_skip_tags An array of Ansible tags to skip (optional)
# @param par_start_at_task The name of the task to start execution at (optional)
# @param par_limit Limit playbook execution to specific hosts (optional)
# @param par_verbose Enable verbose output from Ansible (optional)
# @param par_check_mode Run Ansible in check mode (dry-run) (optional)
# @param par_timeout Timeout in seconds for playbook execution (optional)
# @param par_user Remote user to use for Ansible connections (optional)
# @param par_env_vars Additional environment variables for ansible-playbook execution (optional)
# @param par_logoutput Control whether playbook output is displayed in Puppet logs (optional)
# @param par_exclusive Serialize playbook execution using a lock file (optional)
class paw_ansible_role_firewall (
  Optional[String] $port = undef,
  Optional[String] $rule = undef,
  String $firewall_state = 'started',
  Boolean $firewall_enabled_at_boot = true,
  Boolean $firewall_flush_rules_and_chains = true,
  String $firewall_template = 'firewall.bash.j2',
  Array $firewall_allowed_tcp_ports = ['22', '25', '80', '443'],
  Array $firewall_allowed_udp_ports = [],
  Array $firewall_forwarded_tcp_ports = [],
  Array $firewall_forwarded_udp_ports = [],
  Array $firewall_additional_rules = [],
  Boolean $firewall_enable_ipv6 = true,
  Array $firewall_ip6_additional_rules = [],
  Boolean $firewall_log_dropped_packets = true,
  Boolean $firewall_disable_firewalld = false,
  Boolean $firewall_disable_ufw = false,
  Optional[Stdlib::Absolutepath] $par_vardir = undef,
  Optional[Array[String]] $par_tags = undef,
  Optional[Array[String]] $par_skip_tags = undef,
  Optional[String] $par_start_at_task = undef,
  Optional[String] $par_limit = undef,
  Optional[Boolean] $par_verbose = undef,
  Optional[Boolean] $par_check_mode = undef,
  Optional[Integer] $par_timeout = undef,
  Optional[String] $par_user = undef,
  Optional[Hash] $par_env_vars = undef,
  Optional[Boolean] $par_logoutput = undef,
  Optional[Boolean] $par_exclusive = undef
) {
# Execute the Ansible role using PAR (Puppet Ansible Runner)
# Playbook synced via pluginsync to agent's cache directory
# Check for common paw::par_vardir setting, then module-specific, then default
  $_par_vardir = $par_vardir ? {
    undef   => lookup('paw::par_vardir', Stdlib::Absolutepath, 'first', '/opt/puppetlabs/puppet/cache'),
    default => $par_vardir,
  }
  $playbook_path = "${_par_vardir}/lib/puppet_x/ansible_modules/ansible_role_firewall/playbook.yml"

  par { 'paw_ansible_role_firewall-main':
    ensure        => present,
    playbook      => $playbook_path,
    playbook_vars => {
      'port'                            => $port,
      'rule'                            => $rule,
      'firewall_state'                  => $firewall_state,
      'firewall_enabled_at_boot'        => $firewall_enabled_at_boot,
      'firewall_flush_rules_and_chains' => $firewall_flush_rules_and_chains,
      'firewall_template'               => $firewall_template,
      'firewall_allowed_tcp_ports'      => $firewall_allowed_tcp_ports,
      'firewall_allowed_udp_ports'      => $firewall_allowed_udp_ports,
      'firewall_forwarded_tcp_ports'    => $firewall_forwarded_tcp_ports,
      'firewall_forwarded_udp_ports'    => $firewall_forwarded_udp_ports,
      'firewall_additional_rules'       => $firewall_additional_rules,
      'firewall_enable_ipv6'            => $firewall_enable_ipv6,
      'firewall_ip6_additional_rules'   => $firewall_ip6_additional_rules,
      'firewall_log_dropped_packets'    => $firewall_log_dropped_packets,
      'firewall_disable_firewalld'      => $firewall_disable_firewalld,
      'firewall_disable_ufw'            => $firewall_disable_ufw,
    },
    tags          => $par_tags,
    skip_tags     => $par_skip_tags,
    start_at_task => $par_start_at_task,
    limit         => $par_limit,
    verbose       => $par_verbose,
    check_mode    => $par_check_mode,
    timeout       => $par_timeout,
    user          => $par_user,
    env_vars      => $par_env_vars,
    logoutput     => $par_logoutput,
    exclusive     => $par_exclusive,
  }
}
