# -*- encoding: utf-8 -*-

version = File.read(File.expand_path("../THINKSPACE_VERSION", __FILE__)).strip

Gem::Specification.new do |s|

  s.name         = "thinkspace"
  s.version      = version
  s.authors      = ["Iowa State University/Sixth Edge"]
  s.email        = ["james@sixthedge.com"]
  s.homepage     = "http://www.sixthedge.com"
  s.summary      = "Thinkspace"
  s.description  = "Thinkspace educational platform"
  s.license      = %q{MIT}
  s.require_path = ['lib']

  s.files  = Dir['thinkspace.gemspec', 'README.md', 'LICENSE.md', 'THINKSPACE_VERSION']
  s.files += Dir.glob('lib/**/*')
  s.files += Dir.glob('migrate/**/*')

  s.add_dependency 'totem'
  s.add_dependency 'aasm'

end
