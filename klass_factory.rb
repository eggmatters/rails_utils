
class KlassFactory
  # Creates a deeply nested class instance based on params passed in
  # 
  # @param [Class] instance, instance of a class you wish to attach attributes to
  # @param [Hash] attrs, a (typically) nested set of objects. Must be a top-level hash. Can be a hash of hashes or hash of arrays nested deeply
  # 
  # @returns the class instance, with attrs attached as class instances and class variables
  def self.init instance, attrs
    attr_hash = depthify attrs
    assign_attributes instance, attr_hash[:flat]
    attach_children instance, attr_hash[:deep]
    return instance
  end
    
  # Creates a named class 
  #
  # @param [String] class_name The name of the class
  # Returns an empty class of ClassName 
  def self.create_class class_name
    class_name = class_name.camelize
    class_const = nil
    if Object.const_defined?(class_name)
      class_const = Object.const_get(class_name)
    else
      class_const = Object.const_set(class_name.camelize, Class.new)
    end
    class_instance = class_const.new
    return class_instance
  end
  # 
  # Assigns attributes as instance names to class_instance
  # @param [Class] class_instance a class to assign attributes
  # @param [Hash] attrs a Hash of attributes to assign as instance variables
  def self.assign_attributes class_instance, attrs
    if attrs.respond_to? :each
      attrs.each do |key, val|
        target = "#{key}".to_sym
        class_instance.class.send :attr_accessor, target
        class_instance.instance_variable_set("@#{target}", val)
      end
    end
  end
  #
  # Recursively sets complex types as class instances, children of parent class.
  # 
  # @param [Class] parent_instance, the class instance to attach attrs to
  # @param [Hash] attrs attributes to attach (can be deeply nested)
  def self.attach_children parent_instance, attrs
    if attrs.respond_to? :each
      attrs.each do |key, properties|
        if properties.is_a? Hash
          child = KlassFactory.create_class key.to_s
          KlassFactory.assign_attributes child, properties
          attach_children child, properties
          parent_instance.class.send :attr_accessor, key.to_sym
          parent_instance.instance_variable_set("@#{key}", child)
        end
        if properties.is_a? Array
          child_array = Array.new
          properties.each do |property|
            child = KlassFactory.create_class key.to_s.singularize
            if property.respond_to? :each
              attr_hash = KlassFactory.depthify property
              KlassFactory.assign_attributes child, attr_hash[:flat]
              attach_children child, attr_hash[:deep]
            end
            child_array.push child
          end
          parent_instance.class.send :attr_accessor, key.to_sym
          parent_instance.instance_variable_set("@#{key}", child_array)
        end
      end
    end
  end
  # helper method to separate complex attributes
  # @param attrs
  # returns Hash { :deep => {}, :flat => {} } returns two hashes: deep and flat
  #  
  def self.depthify attrs
    flat = {}
    deep = {}
    if attrs.respond_to? :each
      attrs.each do | key, value |
        if value.is_a? Hash or value.is_a? Array
          deep[key.to_s] = value
        else
          flat[key.to_s] = value
        end
      end
    end
    return { :flat => flat, :deep => deep }
  end
end
