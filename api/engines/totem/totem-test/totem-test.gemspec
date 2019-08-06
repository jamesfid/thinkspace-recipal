# -*- encoding: utf-8 -*-

version = File.read(File.expand_path("../../TOTEM_VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.name         = "totem-test"
  s.version      = version
  s.authors      = ["Sixth Edge"]
  s.email        = [""]
  s.homepage     = "http://www.sixthedge.com"
  s.summary      = "Totem Test"
  s.description  = "The Totem Test engine."
  s.license      = %q{MIT}
  s.require_path = ['lib']

  s.files  = Dir['README.md', 'LICENSE.md']
  s.files += Dir['totem-test.gemspec']
  s.files += Dir.glob('app/**/*')
  s.files += Dir.glob('lib/**/*')
  s.files += Dir.glob('test/**/*')

  s.add_dependency 'totem', version
  s.add_dependency 'totem-seed', version

end
