module Totem::Test::Models
extend ActiveSupport::Concern

  module ModelSave
    def save_model(model)
      unless model.save
        message  = "\n"
        message += "Error saving build model:\n#{model.inspect}.\nValidation errors: #{model.errors.messages}.\n"
        model.errors.keys.each do |key|
          [model.send(key)].flatten.compact.each do |assoc_model|
            next unless is_active_record?(assoc_model)
            next if assoc_model.errors.blank?
            message += "\n#{assoc_model.inspect}\nValidation errors: #{assoc_model.errors.messages}\n"
          end
        end
        raise message
      end
    end
  end

  module ModelMethods

    def is_active_record?(model)
      klass = model.is_a?(Class) ? model : model.class
      klass.ancestors.include?(::ActiveRecord::Base)
    end

    def get_model_association_records_by_class_name(model, class_name)
      assoc_method = get_model_association_method(model, class_name)
      assoc_method.present? ? model.send(assoc_method) : nil
    end

    def get_model_association_method(model, class_name)
      assoc = get_model_association_name(class_name).to_sym
      return assoc if model.respond_to?(assoc)
      assoc = assoc.to_s.pluralize
      return assoc if model.respond_to?(assoc)
      nil
    end

    def get_model_association_name(name); "#{name.underscore.gsub(/\//,'_')}"; end

    def get_association_model_class(assoc)
      class_name = get_association_class_name(assoc)
      class_name && class_name.safe_constantize
    end

    def model_classes_in_same_namespace?(model1, model2)
      return false if model1.blank? || model2.blank?
      model1.name.deconstantize == model2.name.deconstantize
    end

    def get_association_name(assoc);        assoc && assoc.name; end
    def get_association_class_name(assoc);  assoc && assoc.options[:class_name]; end
    def get_association_foreign_key(assoc); assoc && assoc.options[:foreign_key]; end
    def is_through_association?(assoc);     assoc && assoc.options[:through].present?; end
    def is_polymorphic_association?(assoc); assoc && assoc.options[:polymorphic].present?; end

    def is_has_many?(model_class, name)
      assoc = model_class_association(model_class, name)
      assoc && assoc.macro == :has_many
    end

    def is_polymorphic?(model_class, name); name && is_polymorphic_association?(model_class.reflect_on_association(name.to_sym)); end

    def get_belongs_to_associations(model_class);        model_class.reflect_on_all_associations(:belongs_to); end
    def get_all_associations(model_class);               model_class.reflect_on_all_associations; end
    def model_class_association(model_class, name);      name   && model_class.reflect_on_association(name.to_sym); end
    def model_class_has_association?(model_class, name); name   && model_class_association(model_class, name).present?; end
    def model_class_has_method?(model_class, method);    method && model_class.method_defined?(method); end
    def model_class_has_column?(model_class, column);    column && model_class.column_names.include?(column.to_s); end

  end # model methods

  # Models are somewhat unique as the methods may be used at the class level (e.g. model.each loops, seed loads) or
  # at the instance level (e.g. user = get_user(:read_1).
  class_methods do
    include ModelSave
    include ModelMethods
  end

  included do
    include ModelSave
    include ModelMethods
  end

end
