require 'nokogiri'

namespace :thinkspace do
  namespace :html do
    namespace :assets do

      task :rails_to_s3, [] => [:environment] do |t, args|
        dry_run      = ENV['DRY_RUN'] == 'false' ? false : true
        image_prefix = ENV['IMAGE_PREFIX'] 
        image_prefix = 'dry-run://dry-run.com' if dry_run and !image_prefix.present?
        image_prefix.chop! if image_prefix.end_with?('/')

        if !dry_run and !image_prefix.present?
          puts "[ERROR thinkspace:html:assets:rails_to_s3] Cannot run a non-dry run without an IMAGE_PREFIX="
          return
        end

        Thinkspace::Html::Content.all.each do |content|
          html = content.html_content
          doc = Nokogiri::HTML.fragment(html) do |config|
            config.nonet
          end
          images = doc.search('img')
          images.each do |image|
            src                          = image.attribute('src').text
            file_name                    = src.split('/').pop
            puts "[thinkspace:html:assets:rails_to_s3] Src [#{src}] is a relative path for file: [#{file_name}] - new_src: [#{get_image_src_for_file_name(image_prefix, file_name)}]" if src.first == '/'
            image.attribute('src').value = get_image_src_for_file_name(image_prefix, file_name)
          end

          if !dry_run
            content.html_content = doc.to_s
            content.save
          end
        end
      end # /task

      def get_image_src_for_file_name(image_prefix, file_name)
        image_prefix + "/#{file_name}"
      end

    end
  end
end