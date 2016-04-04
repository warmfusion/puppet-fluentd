# == Define: fluentd::filter
#
# Create a fluentd filter
#
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
#   (Array of ) String. Fluent Pattern used to match tags for application
#   Default: "${name}.*"
#
# [*config*]
#    Hash. Hash containing strings, hashes or arrays (1 level deep) to describe your configuration
#          Must include a 'type'
#    Default: undef
#
#
define fluentd::filter (
    $priority      = 10,
    $pattern       = [ "${name}.*" ],
    $config        = undef
  ){

  if !is_integer($priority) {
    fail("fluentd::filter{${name}}: priority must be an integer (got: ${priority})")
  }

  if !$pattern {
    fail("fluentd::filter{${name}}: pattern must be defined (got: ${pattern})")
  }


  unless ($config and $config['type']) or $type {
    fail("fluentd::filter{${name}} 'config' must contain a 'type' key")
  }

  file { "/etc/fluent/conf.d/filters/${priority}-${name}.conf":
    ensure  => 'present',
    content => template('fluentd/conf/filter.erb'),
    notify  => Service['fluentd'],
    owner   => 'fluent',
    group   => 'fluent',
    mode    => '0440',
    require => File['/etc/fluent/conf.d/filters/'],
  }


}
