# -*- encoding: utf-8 -*-

version = File.read(File.expand_path("../../TOTEM_VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.name         = "totem-authorization-cancan"
  s.version      = version
  s.authors      = ["Iowa State University/Sixth Edge"]
  s.email        = ["james@sixthedge.com"]
  s.homepage     = "http://www.sixthedge.com"
  s.summary      = "Totem Authorization Cancan"
  s.description  = "Totem authorization using cancan"
  s.license      = %q{MIT}
  s.require_path = ['lib']

  s.files  = Dir['README.md', 'LICENSE.md']
  s.files += Dir['totem-authorization-cancan.gemspec']
  s.files += Dir.glob('app/**/*')
  s.files += Dir.glob('lib/**/*')

  s.add_dependency 'totem', version

end
