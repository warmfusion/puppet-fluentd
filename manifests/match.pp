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
#    String. Deprecated - set inside content
#    Default: undef
#
# [*type_config*]
#    Hash. Deprecated - use content
#    Default: undef
#
# [*content*]
#    Hash. Hash containing strings, hashes or arrays 
#          (1 level deep) to describe your configuration
#          Must include a type
#    Default: undef
#  
#
define fluentd::match (
    $priority      = 10,
    $pattern       = [ "${name}.*" ],
    $type          = undef,
    $type_config   = undef,
    $config       = undef
  ){

  if !is_integer($priority) {
    fail("fluentd::match{${name}}: priority must be an integer (got: ${priority})")
  }
  if !$pattern {
    fail("fluentd::match{${name}}: pattern must be defined (got: ${pattern})")
  }


  if $type {
    warning("fluentd::match{${name}}: type is deprecated - Please configure type in the 'config' variable)")
  }

  if $type_config {
    warning("fluentd::match{${name}}: type_config is deprecated - Please configure source using the 'config' variable)")
  }


  unless ($config and $config['type']) or $type {
    fail("fluentd::match{${name}} 'config' must contain a 'type' key") # (or type whilst its deprecated)
  }


  file { "/etc/fluent/conf.d/matchers/${priority}-${name}.conf":
    ensure  => 'present',
    owner   => 'fluent',
    group   => 'fluent',
    mode    => '0440',
    content => template('fluentd/conf/match.erb'),
    notify  => Service['fluentd'],
  }


}