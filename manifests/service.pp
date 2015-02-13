class fluentd::service{
    
    service{ 'fluentd':
      ensure => 'running',
    }

    
}