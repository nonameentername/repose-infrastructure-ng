class default_node (
  $puppet_version = "6.2.0-1${lsbdistcodename}"
) {
  include base

  # Hold the Puppet Agent package at the desired version so that Prometheus does not
  # alert us of updates that we don't want to consume.
  apt::pin { 'puppet_agent':
      packages => 'puppet-agent',
      version  => $puppet_version,
      priority => 1001,
  }

  class { 'users': }
  # we want all firewall resources purged, so only the puppet ones apply
  resources { "firewall":
      purge => true
  }
  # resources { 'firewallchain':
  #     purge => true,
  # }

  Firewall {
      before  => Class['base::fw_post'],
      require => Class['base::fw_pre'],
  }

  class { ['base::fw_pre', 'base::fw_post']: }
  class { 'cloud_monitoring': }
  class { 'firewall': }

  # just setting swap size to a 4GB swapfile no matter what
  # if this becomes a problem in the future, change it, or make it more dynamic
  # the base::swap class will base it on the size of the ram, if not specified
  base::swap { 'swapfile':
      swapfile => '/swapfile',
      swapsize => 4096,
  }

  # Installs exporters which enable Prometheus to collect system metrics for monitoring.
  include repose_prometheus
}
