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

Manage a FluentD installation from the community managed Gem, and provide configuration
for your environment using a set of puppet resources.

## Module Description

This module attempts to provide a mechanism to manage a FluentD installation using 
the gem daemons rather than the td-agent packages which are not as well supported on
some systems.

## Setup

### What fluentd affects

* Installs the fluentd gem
* Creates a minimum set of configuration files and directories
* Provides resources to create additional named configuration files to be included automatically
* Manages the fluentd service

### Setup Requirements **OPTIONAL**

TBA

### Beginning with fluentd

The very basic steps needed for a user to get the module up and running.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you may wish to include an additional section here: Upgrading
(For an example, see http://forge.puppetlabs.com/puppetlabs/firewall).

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

### Matcher Configuration

This configuration will setup a nested matching block containing a copy to two stores.

    fluentd::match:
      'nginx.access':
        pattern: 'nginx.*'
        priority: 10
        config:
          type: copy
          store:
           - type: file
             path: /var/log/fluent/myapp
             time_slice_format: %Y%m%d
             time_slice_wait: 10m
             time_format: %Y%m%dT%H%M%S%z
             compress: gzip
             utc: ''
           - type: mongo
             host fluentd
             port 27017
             database fluentd
             collection test


## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

This is where you list OS compatibility, version compatibility, etc.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You may also add any additional sections you feel are
necessary or important to include here. Please use the `## ` header.
