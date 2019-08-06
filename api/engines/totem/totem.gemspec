# -*- encoding: utf-8 -*-

version = File.read(File.expand_path('../TOTEM_VERSION', __FILE__)).strip

Gem::Specification.new do |s|

  s.name         = 'totem'
  s.version      = version
  s.authors      = ['Iowa State University/Sixth Edge']
  s.email        = ['james@sixthedge.com']
  s.homepage     = 'http://www.sixthedge.com'
  s.summary      = 'Totem Core'
  s.description  = 'Totem main configuration engine'
  s.license      = %q{MIT}
  s.require_path = ['lib']

  s.files  = Dir['README.md', 'LICENSE.md', 'TOTEM_VERSION']
  s.files += Dir['totem.gemspec']
  s.files += Dir.glob('lib/**/*')

  s.add_dependency 'totem-core', version

end
