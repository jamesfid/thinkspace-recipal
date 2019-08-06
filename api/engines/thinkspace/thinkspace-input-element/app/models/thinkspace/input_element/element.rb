module Thinkspace
  module InputElement
    class Element < ActiveRecord::Base
      totem_associations

      validates :name, presence: true, uniqueness: {scope: [:componentable_id, :componentable_type]}

      ELEMENT_TYPES = ['text', 'checkbox' ,'textarea', 'select', 'radio']
      ELEMENT_TAGS  = ['input', 'textarea', 'select']

      # Custom tags structure: 'tag-name' => 'tag-type' => {tag-type-options}
      CUSTOM_TAGS = {
        'thinkspace' => {
                          'carry_forward' => {templates: ['response']},
                          'carry_forward_image' => {},
                        },
      }

      def self.element_types; ELEMENT_TYPES; end
      def self.element_tags;  ELEMENT_TAGS; end
      def self.custom_tags;   CUSTOM_TAGS.keys; end

      def self.custom_tag_types(tag)
        return [] if tag.blank?
        types = CUSTOM_TAGS[tag.to_s] && CUSTOM_TAGS[tag.to_s].keys
        types || []
      end
      
      def self.custom_tag_type_templates(tag, type)
        return [] if tag.blank? || type.blank?
        types = (CUSTOM_TAGS[tag.to_s] && CUSTOM_TAGS[tag.to_s][type.to_s]) || {}
        types[:templates] || []
      end

      def is_supported_type?(type)
        return false if type.blank?
        ELEMENT_TYPES.include?(type)
      end

      # ###
      # ### Delete Ownerable Data.
      # ###

      include ::Totem::Settings.module.thinkspace.delete_ownerable_data_helper

      def ownerable_data_associations; [:thinkspace_input_element_responses]; end

    end
  end
end
