# fluentd

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with fluentd](#setup)
    * [What fluentd affects](#what-fluentd-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with fluentd](#beginning-with-fluentd)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

[![Build Status](https://travis-ci.org/warmfusion/puppet-fluentd.svg?branch=master)](https://travis-ci.org/warmfusion/puppet-fluentd)

Manage a FluentD installation from the community managed Gem, and provide configuration
for your environment using a set of puppet resources.

## Module Description

This module attempts to provide a mechanism to manage a FluentD installation using 
the gem daemons rather than the td-agent packages which are not as well supported on
some systems.


The code has been heavily based on the Puppet module created by (mms-srf)[https://github.com/mmz-srf/puppet-fluentd]
as I wanted to try and solve a few perceived problems with that implementation:

1. Avoid use of td-agent and instead use fluentd gem directly
2. Improve flexibility of configuration by enabling multiple nested elements and arrays without hardcoding


## Setup

### What fluentd affects

* Installs the fluentd gem
* Creates a minimum set of configuration files and directories
* Provides resources to create additional named configuration files to be included automatically
* Manages the fluentd service


## Configuration

How to configure the fluentd agent to send data to a centralised Fluentd-Server

### Install a Required Plugin

> WARNING: Plugin configuration is not complete. Do not attempt to use this yet

Install your fluentd plugin. (Check [here](http://fluentd.org/plugin/) for the
right plugin name.)

You can choose from a file or gem based installation.


    include ::fluentd

    fluentd::plugin { 'elasticsearch':
      plugin_type => 'gem',
      plugin_name => 'fluent-plugin-elasticsearch',
    }


### Configure a Source

Sources describe to fluentd where to obtain its data to process. This can include
reading log files, opening tcp ports, running http services etc.



    include ::fluentd

    fluentd::source { 'apache':
      config => {
        'format'   => 'apache2',
        'path'     => '/var/log/apache2/access.log',
        'pos_file' => '/var/tmp/fluentd.pos',
        'tag'      => 'apache.access_log',
        'type'     => 'tail',
      },
    }

    fluentd::source { 'syslog':
      config => {
        'format'   => 'syslog',
        'path'     => '/var/log/syslog',
        'pos_file' => '/tmp/td-agent.syslog.pos',
        'tag'      => 'system.syslog',
        'type'     => 'tail',
      },
    }


### Match configuration

    fluentd::match { 'forward':
      pattern  => '**',
      priority => '80',
      config   => {
        'type'    => 'forward',
        'servers' => [
          { 'host' => 'fluentd.example.com', 'port' => '24224' }
        ],
      },
    }


#### Forest Pluging configuration

This is an example of having key/value configuration for nested elements other than
the 'server' elements usually seen - This example is based on using the (forest configuration)[https://github.com/tagomoris/fluent-plugin-forest] 
plugin to manage the configuration of a (fluentd-plugin-elasticsearch)[https://github.com/uken/fluent-plugin-elasticsearch] gem.


    fluentd::match { 'forest-es':
      pattern  => '**',
      priority => '10',
      config   => {
        'type'    => 'forst',
        'subtype' => 'elasticsearch',
        'remove_prefix' => 'my.logs',
        'template' => [
          { 
            'host' => 'elasticsearch.example.com', 
            'port' => 9200 
            'logstash_prefix' => ${tag[1]},
          }
        ],
      },
    }

#### Forwarder with Secondary

This is a very complicated example, based on the documentation of an (out forwarder)[http://docs.fluentd.org/articles/out_forward]


    fluentd::match { 'forwarder-safe':
      pattern  => '**',
      priority => '10',
      config   => {
        'type'  =>  'forward',
        'send_timeout'  =>  '60s',
        'recover_wait'  =>  '10s',
        'heartbeat_interval'  =>  '1s',
        'phi_threshold'  =>  '16',
        'hard_timeout'  =>  '60s',

        'server' => [
        {
           'name'  =>  'myserver1',
           'host'  =>  '192.168.1.3',
           'port'  =>  '24224',
           'weight'  =>  '60',
         },{
           'name'  =>  'myserver2',
           'host'  =>  '192.168.1.4',
           'port'  =>  '24224',
           'weight'  =>  '60',
         }
        ],
        'secondary' => {
         'type'  =>  'file',
         'path'  =>  '/var/log/fluent/forward-failed',
        }
      }
    }



## TODO

 [ ] - Plugin management
 [ ] - Remove MASSIVE duplication of effort between source and match config - its basically the same thing twice

## Development


