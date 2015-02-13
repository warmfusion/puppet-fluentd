# == Define: fluentd::source
#
# Create a fluentd source element for a service
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
# [*priority*]
#   Integer. Prefix to the filename to enforce sequential ordering of matches
#   Default: 10
#
#
# [*type*]
#    String. Output plugin type to send events to, eg file, forward, http etc
#    Default: undef
#
# [*type_config*]
#    Hash. Configuration for type has a key/value hash
#    Default: undef
#
# [*ensure*]
#    String. Ensure that this source configuration is [present, absent]
#    Default: present
#
# [*plugin_name*]
#    String. Plugin to ensure exists to use this type
#    Default: $type
#
# [*plugin_ensure*]
#    String. Ensure that this plugin is 'present', 'absent', 'latest', etc
#    Default: 'present'
#  
#
define fluentd::source (
    $priority      = 10,
    $type          = undef,
    $type_config   = undef,
    $ensure        = 'present',
    $plugin_name   = undef,
    $plugin_ensure = 'present',
  ){

  if !is_integer($priority) {
    fail("fluentd::source{${name}}: priority must be an integer (got: ${priority})")
  }

  validate_re($ensure, ['^absent$', '^present$' ], "fluentd::source{${name}}: ensure must be either present or absent (got: ${ensure})")


  if !$type {
    fail("fluentd::source{${name}}: type must be set)")
  }

  file { "/etc/fluent/conf.d/sources/${priority}-${name}.conf":
    ensure  => $ensure,
    content => template('fluentd/conf/source.erb'),
    notify  => Service['fluentd'],
    owner   => 'fluent',
    group   => 'fluent',
    mode    => '0440',
    require => File['/etc/fluent/conf.d/sources/'],
  }

  if $package_name { 
      package{ "${plugin_name}":
        ensure => "${plugin_ensure}",
        provider => 'fluentd-gem',
        notify  => Service['fluentd'],
      }
  }


}
