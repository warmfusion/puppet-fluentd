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
        '/etc/fluent/conf.d/matchers/',
        '/etc/fluent/conf.d/filters/',
        ]
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
        require => File['/etc/default/fluentd']
    }

    file{ '/etc/default/fluentd':
        ensure  => 'present',
        content => template('fluentd/etc/default/fluentd.erb'),
        owner   => 'fluent',
        group   => 'fluent',
        mode    => '0755',
        notify  => Service['fluentd']
    }

    logrotate::rule { 'fluent':
        path          => '/var/log/fluent/fluentd.log',
        rotate_every  => 'day',
        missingok     => true,
        rotate        => '30',
        compress      => true,
        delaycompress => true,
        ifempty       => false,
        create        => true,
        create_mode   => '0640',
        create_owner  => 'fluent',
        create_group  => 'fluent',
        sharedscripts => true,
        postrotate    => '[ ! -f /var/run/fluent/fluentd.pid ] || kill -USR1 `cat /var/run/fluent/fluentd.pid`',
        require       => [ User['fluent'], Group['fluent'] ]
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
