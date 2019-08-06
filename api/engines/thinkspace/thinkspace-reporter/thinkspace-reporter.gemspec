# -*- encoding: utf-8 -*-

version = File.read(File.expand_path('../../THINKSPACE_VERSION', __FILE__)).strip

Gem::Specification.new do |s|

  s.name        = 'thinkspace-reporter'
  s.version      = version
  s.authors      = ['Iowa State University/Sixth Edge']
  s.email        = ['james@sixthedge.com']
  s.homepage     = 'http://www.thinkspace.org'
  s.summary     = 'Thinkspace reporter'
  s.description = 'Thinkspace reporter engine'
  s.license      = %q{MIT}
  s.require_path = ['lib']

  s.files  = Dir['README.md', 'LICENSE.md']
  s.files += Dir['thinkspace-reporter.gemspec']
  s.files += Dir.glob('app/**/*')
  s.files += Dir.glob('config/**/*')
  s.files += Dir.glob('db/**/*')
  s.files += Dir.glob('lib/**/*')

end
