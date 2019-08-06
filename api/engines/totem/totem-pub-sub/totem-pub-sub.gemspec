# -*- encoding: utf-8 -*-

version = File.read(File.expand_path("../../TOTEM_VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.name         = "totem-pub-sub"
  s.version      = version
  s.authors      = ["Iowa State University/Sixth Edge"]
  s.email        = ["james@sixthedge.com"]
  s.homepage     = "http://www.sixthedge.com"
  s.summary      = "Totem PubSub"
  s.description  = "Totem PubSub engine"
  s.license      = %q{MIT}
  s.require_path = ['lib']

  s.files  = Dir['README.md', 'LICENSE.md']
  s.files += Dir['totem-pub-sub.gemspec']
  s.files += Dir.glob('app/**/*')
  s.files += Dir.glob('config/**/*')
  s.files += Dir.glob('lib/**/*')

  s.add_dependency 'totem', version

end
