# == Class: fluentd
#
# Full description of class fluentd here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'fluentd':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class fluentd (
    $ensure       = 'present',
    $user_groups  = ['fluent'],
    $package_name     = $::fluentd::params::package_name,
    $package_provider = $::fluentd::params::package_provider
    ) inherits ::fluentd::params{

  validate_re($ensure,
    ['^absent$', '^installed$', '^latest$', '^present$', '^[\d\.\-]+$'],
    "Invalid fluentd ensure : ${ensure}")


  # Include everything and let each module determine its state.  This allows
  # transitioning to purged config and stopping/disabling services
  anchor { 'fluentd::begin': } ->
  class { 'fluentd::package': } ->
  class { 'fluentd::service': } ->
  anchor {'fluentd::end': }
}
