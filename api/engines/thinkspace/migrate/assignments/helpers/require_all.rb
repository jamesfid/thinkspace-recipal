require 'nokogiri'
require 'pp'

# helpers
helper_files = Dir.glob(File.expand_path("../*.rb", __FILE__))
helper_files.each do |file|
   next if File.basename(file) == File.basename(__FILE__)
   require file
end
