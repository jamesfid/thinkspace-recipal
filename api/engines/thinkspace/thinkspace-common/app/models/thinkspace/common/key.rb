require 'csv'

module Thinkspace
  module Common
    class Key < ActiveRecord::Base
      totem_associations
      validates_uniqueness_of :key

      def self.generate(number=0, options={})
        source   = options[:source]   || nil
        category = options[:category] || nil
        records  = []
        number.times.each do |num|
          record = self.create_record(options)
          records << record
        end
        csv = CSV.generate do |f|
          f << ['source', 'category', 'key']
          records.each do |r|
            f << [r.source, r.category, r.key]
          end
        end
        puts "\n CSV string for keys: \n"
        puts csv
        return records
      end

      def self.generate_key; SecureRandom.urlsafe_base64(10).tr('lIO0', 'sxyz'); end
      def self.create_record(options={})
        source     = options[:source]   || nil
        category   = options[:category] || nil
        expires_at = options[:expires_at] || nil
        key        = generate_key
        self.create(source: source, category: category, key: key, expires_at: expires_at)
      end

      def set_expires_at!(duration=6); self.expires_at = Time.now + duration.months; self.save; end
      def has_expired?;   expires_at < Time.now; end
      
    end
  end
end
