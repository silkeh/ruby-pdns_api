require File.expand_path('../lib/pdns_api/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'pdns_api'
  s.version     = PDNS::VERSION
  s.date        = '2016-05-30'
  s.summary     = 'PowerDNS API gem'
  s.description = 'A gem for manipulation of DNS through the PowerDNS API'
  s.homepage    = 'https://github.com/silkeh/ruby-pdns_api'
  s.license     = 'EUPL'

  s.authors     = ['Silke Hofstra']
  s.email       = 'silke@slxh.eu'

  s.files         = Dir['{lib}/**/*']
  s.require_paths = ['lib']
end
