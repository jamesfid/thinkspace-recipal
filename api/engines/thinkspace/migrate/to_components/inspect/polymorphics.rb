module Thinkspace; module Migrate; module ToComponents; module Inspect
  class Polymorphics < Totem::DbMigrate::BaseHelper
    require 'pp'

    def process
      tables = get_new_db_tables
      print_polymorphics(tables)
    end

    def print_polymorphics(tables)
      no_poly_scopes = Array.new
      collect        = Array.new
      puts "\n"
      tn_len   = 50
      poly_len = 15
      cnt_len  = 5
      puts 'Table'.ljust(tn_len,'-') + '  ' + 'Polymorphic'.ljust(poly_len,'-') + '  ' + 'Total'.rjust(cnt_len) + ' ' + '#nil'.rjust(cnt_len) + ' ' + '#ids'.rjust(cnt_len) + ' ' + 'Polymorphic Types'.ljust(40,'-')
      tables.sort.each_with_index do |table_name, index|
        klass = get_table_model_class(table_name, index)
        if klass.blank?
          puts "Model class #{model_class.inspect} for table name #{table_name.inspect} could not be constantized."
          next
        end
        cols   = klass.column_names
        polys  = cols.select {|c| c.end_with?('able_type')}
        polys.sort.each do |type_poly|
          id_poly       = type_poly.sub(/_type$/, '_id')
          cnt           = klass.count
          no_type       = klass.where(type_poly => nil)
          no_id         = klass.where(id_poly => nil)
          no_type_count = no_type.count
          no_id_count   = no_id.count
          types         = klass.all.pluck(type_poly.to_sym).uniq
          puts "#{table_name.ljust(tn_len,'.')}: #{type_poly.sub(/_type$/,'').ljust(poly_len,'.')}: #{cnt.to_s.rjust(cnt_len)} #{no_type_count.to_s.rjust(cnt_len)} #{no_id_count.to_s.rjust(cnt_len)} #{types.join(',')}"
          if no_type_count > 0 || no_id_count > 0
            no_poly_scopes.push(no_type)
            collect.push(klass)  if type_poly == 'ownerable_type'
          end
        end
      end
      puts "\n"
      # puts "Records with nil polymorphics:" 
      # puts "\n"
      # # print_records(no_poly_scopes, 2)
      # print_collections(collect, 'ownerable')
      # puts "\n"
    end

    def print_collections(klasses, poly)
      klasses.each do |klass|
        klass.all.each do |record|
          print_it = record.user_id != record.ownerable_id
          puts "User ID: #{record.user_id.to_s.rjust(5)}  Ownerable: #{record.ownerable_type}.#{record.ownerable_id}"  if print_it
        end
      end
      puts "\n"
    end

    def print_records(scopes, limit=nil)
      scopes.each do |scope|
        scope = limit.present? ? scope.limit(limit) : scope
        scope.each do |record|
          puts record.class.table_name
          pp record
          puts "\n"
        end
      end
      puts "\n"
    end

    def get_table_model_class(table_name, index)
      extend_name = 'ActiveRecord::Base'
      model_name  = "Temp#{index}"
      model_class = "Thinkspace::Migrate::#{model_name}"
      eval <<-DYN_CLASS
        class #{model_class} < #{extend_name}
          self.table_name = #{table_name.inspect}
        end
      DYN_CLASS
      model_class.safe_constantize
    end

  end
  
end; end; end; end
