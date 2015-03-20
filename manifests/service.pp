# == Define: fluentd::service
#
# Ensure that the fluentd service is running
#
# === Parameters
#
# None
#
# === Variables
#
# None  
#
class fluentd::service{
    
    service{ 'fluentd':
      ensure => 'running',
    }

    
}