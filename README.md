Ruby PowerDNS API interface
===========================

[![Gem Version](https://badge.fury.io/rb/pdns_api.svg)](https://badge.fury.io/rb/pdns_api)
[![Inline docs](https://inch-ci.org/github/silkeh/ruby-pdns_api.svg)](https://inch-ci.org/github/silkeh/ruby-pdns_api)
[![Documentation](https://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/github/silkeh/ruby-pdns_api/master)

A ruby client for version 0 and 1 of the PowerDNS HTTP API.

Installation
------------
Install like any ruby gem:

    gem install pdns_api

Or add the following to your Gemfile:

    gem 'pdns_api'

Usage
-----
For any action, an instance of `PDNS::Client` is required with the proper credentials:

```ruby
require 'pdns_api'

pdns = PDNS::Client.new(
  host:    'ns0.example.com',
  port:    8081,
  key:     'secret',
  version: 1
)
```

`port` and `version` are optional and default to `8081` and `1` respectively.

From here a list of servers can be requested with:

```ruby
servers = pdns.servers
```

Or a zone can be requested from the `localhost` server:

```ruby
zone = pdns.servers('localhost').zone('example.com')
```

Example
-------

This example connect to a server, creates a zone (`example.com`),
and adds two records.

```ruby
require 'pdns_api'

pdns = PDNS::Client.new(
  host:    'ns0.example.com',
  key:     'secret',
  version: 1
)

zone = pdns.server('localhost').zone('example.com.')
zone.create(
  name: zone.id,
  kind: 'Native',
  dnssec: true,
  nameservers: %w( ns0.example.com. ns1.example.com. )
)
zone.update({
              name: 'www.example.com.',
              type: 'AAAA',
              ttl:  86400,
              records: '2001:db8::1'
            }, {
              name: 'mail.example.com.',
              type: 'AAAA',
              ttl:  2880,
              records: %w( 2001:db8::1 2001:db8:cff::1 )
            })
```
