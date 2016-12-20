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
#
# [*ensure*]
#   String. Controls if the managed resources shall be <tt>present</tt> or
#   <tt>absent</tt>
#   Defaults to <tt>present</tt>.
#
# [*priority*]
#   Integer. Prefix to the filename to enforce sequential ordering of matches
#   Default: 10
#
#
# [*type*]
#    String. Deprecated - set inside config
#    Default: undef
#
# [*type_config*]
#    Hash. Deprecated - use config
#    Default: undef
#
# [*config*]
#    Hash. Hash containing strings, hashes or arrays (1 level deep) to describe your configuration
#          Must include a type
#    Default: undef
#  
#
define fluentd::source (
    $ensure       = 'present',
    $priority      = 10,
    $type          = undef,
    $type_config   = undef,
    $config        = undef
  ){

  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("fluentd::source{${name}}: ensure must be a string of 'present' or 'absent' (got ${ensure}")
  }

  if !is_integer($priority) {
    fail("fluentd::source{${name}}: priority must be an integer (got: ${priority})")
  }


  if $type {
    warning("fluentd::source{${name}}: type is deprecated - Please configure type in the 'config' variable)")
  }

  if $type_config {
    warning("fluentd::source{${name}}: type_config is deprecated - Please configure source using the 'config' variable)")
  }


  unless ($config and $config['type']) or $type {
    fail("fluentd::source{${name}} 'config' must contain a 'type' key") # (or type whilst its deprecated)
  }

  file { "/etc/fluent/conf.d/sources/${priority}-${name}.conf":
    ensure  => 'present',
    content => template('fluentd/conf/source.erb'),
    notify  => Service['fluentd'],
    owner   => 'fluent',
    group   => 'fluent',
    mode    => '0440',
    require => File['/etc/fluent/conf.d/sources/'],
  }


}
