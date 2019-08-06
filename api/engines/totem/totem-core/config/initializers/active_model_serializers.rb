ActiveModel::Serializer::Association::HasOne.class_eval do
  def root
    if root = options[:root]
      root
    elsif polymorphic?
      # Removed demodulize.
      # Added handling for base class (polymorphic pointing to a STI'd table.)
      # Have to remove .to_sym here because our roots are passed in as a string.
      # This causes polymorphics to key off of :"key" instead of "key" and will mess up ember.
      object.class.base_class.to_s.pluralize.underscore
    else
      name.to_s.pluralize
    end
  end

  def polymorphic_key
    # Removed demodulize.
    # Added handling for base class (polymorphic pointing to a STI'd table.)
    object.class.base_class.to_s.underscore.to_sym
  end
end

ActiveModel::Serializer.class_eval do
  def root_name
    # Have to remove the demodulize for this as well.
    return false if self._root == false
    class_name = self.class.name.underscore.sub(/_serializer$/, '').to_sym unless self.class.name.blank?
    self._root || class_name
  end
end