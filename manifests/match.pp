# == Define: fluentd::match
#
# Create a fluentd match element for a service
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
# [*pattern*]
#   Array. Tag matching pattern(s) to use
#   Default: [ ${name}.* ]
#
# [*type*]
#    String. Output plugin type to send events to, eg file, forward, http etc
#    Default: undef
#
# [*type_config*]
#    Hash. Configuration for type has a key/value hash
#    Default: undef
#  
#
define fluentd::match (
    $priority      = 10,
    $pattern       = [ "${name}.*" ],
    $config        = undef,
  ){

  if !is_integer($priority) {
    fail("fluentd::match{${name}}: priority must be an integer (got: ${priority})")
  }
  if !$pattern {
    fail("fluentd::match{${name}}: pattern must be defined (got: ${pattern})")
  }
  if !$config {
    fail("fluentd::match{${name}}: config must be set)")
  }

  file { "/etc/fluent/conf.d/matchers/${priority}-${name}.conf":
    ensure  => $ensure,
    owner   => 'fluent',
    group   => 'fluent',
    mode    => '0440',
    content => template('fluentd/conf/match.erb'),
    notify  => Service['fluentd'],
  }


}