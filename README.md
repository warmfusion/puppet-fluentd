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

### Install a Plugin

> WARNING: This is not complete. Do not attempt to use this

Install your fluentd plugin. (Check [here](http://fluentd.org/plugin/) for the
right plugin name.)

You can choose from a file or gem based installation.

```
include ::fluentd

fluentd::plugin { 'elasticsearch':
  plugin_type => 'gem',
  plugin_name => 'fluent-plugin-elasticsearch',
}
```

### Configure a Source

Sources describe to fluentd where to obtain its data to process. This can include
reading log files, opening tcp ports, running http services etc.


```
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


...creates the following files:

```
/etc/fluentd/
  ├── conf.d
  │   ├── matchers
  │   │   └── 80-forward.conf
  │   └── sources
  │       ├── 10-apache.conf
  │       └── 10-syslog.conf
  ├── ...
  ...
```



## TODO

 [ ] - Plugin management
 [ ] - Remove MASSIVE duplication of effort between source and match config - its basically the same thing twice

## Development


