Ruby PowerDNS API interface
===========================

Example
-------

This example connect to a server, creates a zone (`example.com`),
and adds two records.

```ruby
require 'pdns'

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
  nameservers: %w{ ns0.example.com. ns1.example.com. }
)
zone.update(
  {
    name: 'www.example.com.',
    type: 'AAAA',
    ttl:  86400,
    records: '2001:db8::1'
  },{
    name: 'mail.example.com.',
    type: 'AAAA',
    ttl:  2880,
    records: %w{ 2001:db8::1 2001:db8:cff::1 }
  }
)
```
