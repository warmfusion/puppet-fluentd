source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_GEM_VERSION') ? "#{ENV['PUPPET_GEM_VERSION']}" : ['>= 3.3']
gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'puppet-lint', '>= 0.3.2'
gem 'facter', '>= 1.7.0'
gem 'rspec', '>= 3.0'

group :development, :test do
  gem 'rake', :require => false
  gem 'rspec-puppet', :require => false
  gem 'rspec-system', :require => false
  gem 'rspec-system-puppet', :require => false
end
