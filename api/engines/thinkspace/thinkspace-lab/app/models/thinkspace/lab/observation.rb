module Thinkspace
  module Lab
    class Observation < ActiveRecord::Base        
      validates_presence_of :thinkspace_lab_result
      totem_associations
      has_paper_trail

      def category_observation_keys; self.thinkspace_lab_category.observation_keys; end

      def locked_state;   'locked'; end
      def unlocked_state; 'unlocked'; end

      def is_updateable?
        self.state != locked_state
      end

      # ###
      # ### Metadata.
      # ###

      def get_metadata(result=nil, category=nil)
        result   = self.thinkspace_lab_result
        category = self.thinkspace_lab_category
        (category.metadata || Hash.new).deep_merge(result.metadata || Hash.new)
      end

      def get_key_metadata(key, metadata=nil)
        metadata ||= get_metadata
        metadata[key] || Hash.new
      end
      
      # ###
      # ### Observation.
      # ###

      def get_key_value(key); self.value[key]; end

      def get_key_last_value(key); get_key_archive(key)[values_key].last; end

      def get_key_attempts(key); get_key_detail(key)[attempts_key]; end

      def get_key_detail(key)
        self.detail[key].reverse_merge!({
          attempts_key => 0,
        })
      end
      
      def get_key_archive(key)
        self.archive[key].reverse_merge!({
          values_key => [],
        })
      end

      def set_state(obs_state); self.state = obs_state; end
      def set_all_correct(val); self.all_correct = val; end
      def increment_attempts;   self.attempts += 1; end

      # ###
      # ### Observation Key.
      # ###

      # In the future could format key value based on metadata e.g. string, number, date, etc. (currently assumes string and metadata not used).
      def set_key_value(key, val, options={})
        # metadata        = get_key_metadata(key, options)
        key_value       = val.nil? ? nil : val.to_s.strip
        self.value[key] = key_value
        key_value
      end

      def set_key_correct(key, val, options={}); self.detail[key][correct_key] = key_value_correct?(key, val, options); end

      def set_key_locked(key, val); self.detail[key][locked_key] = val; end

      def set_key_attempts_exceeded(key, val); self.detail[key][attempts_exceeded_key] = val; end

      def set_key_attempts(key, val); self.detail[key][attempts_key] = val; end

      def increment_key_attempts(key); set_key_attempts(key, get_key_attempts(key) + 1); end

      def add_key_archive_value(key, val); get_key_archive(key)[values_key].push(val); end

      def set_key_values(value_hash={}, options={})
        init_json_columns
        obs_state = unlocked_state
        metadata  = options[:metadata] || get_metadata
        keys      = options[:keys]     || category_observation_keys
        self.value.merge!(value_hash.stringify_keys)
        all_correct = true
        keys.each do |key|
          next if key_defined_as_no_value?(key, metadata: metadata)
          init_key_json(key)
          val         = set_key_value(key, get_key_value(key), metadata: metadata)  # format the key value e.g. currently assumes string.strip
          correct     = set_key_correct(key, val, metadata: metadata)
          all_correct = false if correct.blank?
          # Add value to archive unless same as last observation value.
          unless (val.nil? || val == get_key_last_value(key))
            add_key_archive_value(key, val)
            increment_key_attempts(key)
          end
          key_state = set_key_state(key, metadata: metadata)
          obs_state = key_state unless obs_state == locked_state  # locked by a key, so do not unlock
         end
         set_all_correct(all_correct)
         set_state(obs_state)  # overall observation state
      end

      def key_defined_as_no_value?(key, options={})
        metadata = get_key_metadata(key, options[:metadata])
        metadata[no_value_key] == true
      end

      def set_key_state(key, options={})
        metadata = get_key_metadata(key, options[:metadata])
        max      = metadata[max_attempts_key]
        case
        when max.blank? || max.to_s == 'no_limit'
          set_key_locked(key, false)
          set_key_attempts_exceeded(key, false)
          unlocked_state
        when (not lock_on_max_attempts?(key))
          set_key_locked(key, false)
          set_key_attempts_exceeded(key, max <= get_key_attempts(key))
          unlocked_state
        when max > get_key_attempts(key)
          set_key_locked(key, false)
          set_key_attempts_exceeded(key, false)
          unlocked_state
        else
          set_key_locked(key, true)
          set_key_attempts_exceeded(key, max <= get_key_attempts(key))
          locked_state
        end
      end

      def lock_on_max_attempts?(key, options={})
        metadata  = get_key_metadata(key, options[:metadata])
        metadata[lock_on_max_attempts_key] != false
      end

      def key_value_correct?(key, val, options={})
        metadata = get_key_metadata(key, options[:metadata])
        validate = metadata[validate_key] || Hash.new
        return key_value_correct_method(key, val, options)  if validate.has_key?(correct_method_key)
        correct  = validate[correct_key]
        multiple = validate[multiple_key]
        correct  = [correct].flatten.compact.collect {|c| c.downcase}
        case
        when any_key_value_correct?(correct)
          true
        when val.nil?
          false
        when multiple.blank?
          val = val.downcase  if val.is_a?(String)
          # Only need to match one of the correct values.
          correct.include?(val)
        else
          val = val.downcase  if val.is_a?(String)
          # Mutiple values possible, split on comma to get the values then check againt correct values.
          match_all = validate[multiple_match_all_key]
          val       = val.split(',').each {|v| v.strip}
          if match_all.present?
            correct.length == val.length && (correct - val).blank?
          else
            correct.include?(val)
          end
        end
      end

      # TODO: Need to implement specific method validation.
      def key_value_correct_method(key, val, options={})
        metadata = get_key_metadata(key, options[:metadata])
        validate = metadata[validate_key] || Hash.new
        method   = validate[correct_method_key]
        case
        when method.blank?
          false
        when method == 'standard_adjusted'
          correct = validate[correct_key]
          val.to_f == correct.to_f # TODO: Make more friendly with rounding, etc.
        else
          false
        end
      end

      def any_key_value_correct?(correct)
        correct.blank? || (correct.length == 1 && correct.first.to_s == 'anything')  # Blank correct value in metadata for key, assumes true.
      end

      # Provide consistency for detail/archive json keys.
      def values_key;               'values'; end
      def locked_key;               'locked'; end
      def all_correct_key;          'all_correct'; end
      def correct_key;              'correct'; end
      def correct_method_key;       'correct_method'; end
      def attempts_key;             'attempts'; end
      def attempts_exceeded_key;    'attempts_exceeded'; end
      def max_attempts_key;         'max_attempts'; end
      def no_value_key;             'no_value'; end
      def validate_key;             'validate'; end
      def multiple_key;             'multiple'; end
      def multiple_match_all_key;   'multiple_match_all'; end
      def lock_on_max_attempts_key; 'lock_on_max_attempts'; end

      def init_json_columns
        self.value   ||= Hash.new
        self.detail  ||= Hash.new
        self.archive ||= Hash.new
      end

      def init_key_json(key)
        self.detail[key]  ||= Hash.new
        self.archive[key] ||= Hash.new
      end

    end
  end
end
