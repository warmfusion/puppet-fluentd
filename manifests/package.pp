class fluentd::package{
    
    package{ 'fluentd':
      provider => 'gem',
      ensure=> 'present',
    }

    $dirs = [ '/etc/fluent','/etc/fluent/conf.d','/etc/fluent/conf.d/sources',
        '/etc/fluent/conf.d/matchers/', '/var/log/fluent', '/var/run/fluent' ]
    file{ $dirs:
        ensure => 'directory',
        owner   => 'fluent',
        group   => 'fluent',
        mode    => 0755,
    }

    file{ '/etc/fluent/fluent.conf':
        ensure => 'present',
        content => 'include conf.d/*/*',
        require => File['/etc/fluent'],
        owner   => 'fluent',
        group   => 'fluent',
        mode    => 0440,
    }

    file{ '/etc/init.d/fluentd':
        ensure  => 'present',
        content => template('fluentd/etc/init.d/fluentd.erb'),
        owner   => 'fluent',
        group   => 'fluent',
        mode    => 0755,
    }

    user { 'fluent':
        gid    => 'fluent',
        groups => $fluentd::user_groups,
        shell  => '/bin/true',
        home   => '/etc/fluent',
        forcelocal => true,
    }
    group { 'fluent' :
        ensure => 'present'
    }
}