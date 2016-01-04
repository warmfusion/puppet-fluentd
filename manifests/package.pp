# == Define: fluentd::package
#
# Ensure that the fluentd package is installed and configured
#
# === Parameters
#
# None
#
# === Variables
#
# None  
#
class fluentd::package{
    
    package{ $::fluentd::package_name:
      ensure   => 'present',
      provider => $::fluentd::package_provider,
    }

    $dirs = [ '/etc/fluent', '/var/log/fluent', '/var/run/fluent' ]
    file{ $dirs:
        ensure => 'directory',
        owner  => 'fluent',
        group  => 'fluent',
        mode   => '0755',
    }

    $exlusive_dirs = [ '/etc/fluent/conf.d',
        '/etc/fluent/conf.d/sources',
        '/etc/fluent/conf.d/matchers/']
    file {$exlusive_dirs:
        ensure  => 'directory',
        owner   => 'fluent',
        group   => 'fluent',
        mode    => '0755',
        purge   => true,
        recurse => true,
    }

    file{ '/etc/fluent/fluent.conf':
        ensure  => 'present',
        content => 'include conf.d/*/*',
        require => File['/etc/fluent'],
        owner   => 'fluent',
        group   => 'fluent',
        mode    => '0440',
    }

    file{ '/etc/init.d/fluentd':
        ensure  => 'present',
        content => template('fluentd/etc/init.d/fluentd.erb'),
        owner   => 'fluent',
        group   => 'fluent',
        mode    => '0755',
    }

    file {'/etc/logrotate.d/fluent':
        ensure  => 'present',
        source  => 'puppet:///modules/fluentd/fluentd.logrotate',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package[ $::fluentd::package_name ]
    }

    user { 'fluent':
        gid        => 'fluent',
        groups     => $fluentd::user_groups,
        shell      => '/bin/true',
        home       => '/etc/fluent',
        system     => true,
        forcelocal => true,
    }
    group { 'fluent' :
        ensure     => 'present',
        system     => true,
        forcelocal => true,
    }
}
