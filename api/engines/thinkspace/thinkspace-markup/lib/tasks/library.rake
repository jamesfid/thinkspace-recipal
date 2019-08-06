require 'open-uri'
require 'nokogiri'
require 'smarter_csv'
require 'csv'

namespace :thinkspace do
  namespace :markup do
    namespace :library do
      task :import, [] => [:environment] do |t, args|
        user_id = ENV['USER_ID']
        url     = ENV['URL']
        raise "[library:import] Cannot proceed without a valid user_id [#{user_id}]." unless user_id.present?
        raise "[library:import] Cannot proceed without a valid URL [#{url}]." unless url.present?
        user = Thinkspace::Common::User.find_by(id: user_id)
        raise "[library:import] User is not valid for id: [#{user_id}]." unless user.present?
        library = Thinkspace::Markup::Library.find_or_create_by(user_id: user.id)
        puts "[library:import] Using library: [#{library.inspect}] \n"
        puts "[library:import] Loading file from URL: [#{url}] \n"
        csv      = open(url)
        options  = { headers_in_file: false, user_provided_headers: ['html', 'tags'] }
        comments = SmarterCSV.process(csv, options)
        comments.each_with_index do |comment, i|
          html = comment[:html]
          html = html.force_encoding(Encoding::UTF_8) if html.present?
          html = Nokogiri::HTML.fragment(html) do |config|
            config.nonet
          end
          tags = comment[:tags]
          add_new_library_comment(user, library, CGI.unescapeHTML(html.to_html), tags)
        end
        library.save
      end

      def library_comment_class; Thinkspace::Markup::LibraryComment; end
      def add_new_library_comment(user, library, html, tags)
        existing = library_comment_class.find_by(comment: html, library_id: library.id)
        if existing.present?
          tag_match = true
          if tags.present?
            tags.split(',').each do |tag|
              tag_match = false unless existing.all_tags_list.include?(tag)
            end
          end
          return unless tag_match
        end
        comment = library_comment_class.create(comment: html, uses: 0, library_id: library.id, user_id: user.id)
        puts "[library:import] Created comment: [#{comment.inspect}] \n"
        puts "[library:import] Processing tags: [#{tags}] \n"
        if tags.present?
          puts "[library:import] Tagging comment with tags [#{tags}] \n"
          
          tags.split(',').each do |tag|
            library.tag_list.add(tag) unless library.all_tags.include?(tag)
          end

          library.tag(comment, with: tags, on: :tags)
        end
      end

      task :export, [] => [:environment] do |t, args|
        library_id = ENV['LIBRARY_ID']
        raise "Cannot export a library with a valid id [#{library_id}]" unless library_id
        library = Thinkspace::Markup::Library.find(library_id)
        raise "Cannot export a library if the record does not exist [#{library_id}]" unless library.present?
        comments = library.thinkspace_markup_library_comments
        rows     = []
        comments.each do |comment|
          result = []
          result.push(comment.comment)
          tags = comment.tags.pluck(:name).join(',')
          result.push(tags)
          rows.push(result)
        end
        headers = ['Comment', 'Tags']
        CSV.open(Rails.root.join("spreadsheets/library-#{library_id}-#{Time.now}.csv"), "w") do |csv|
          csv << headers
          rows.each { |row| csv << row }
        end
      end

    end
  end
end
