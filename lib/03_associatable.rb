require_relative '02_searchable'
require 'active_support/inflector'
# require 'byebug'
# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    class_name.constantize
  end

  def table_name
    # ...
    return "humans" if class_name == "Human"
    class_name.downcase.underscore.pluralize
  end
end


class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    defaults = {
      primary_key: :id,
      foreign_key: "#{name.to_s.underscore}_id".to_sym,
      class_name: name.to_s.camelcase
    }

    defaults.keys.each do |k|
      if options[k].nil?
        options[k] = defaults[k]
      end
    end
    @primary_key = options[:primary_key]
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]

  end
end


# class HasManyOptions < AssocOptions
#   def initialize(name, self_class_name, options = {})
#     # ...
#     defaults = {
#       primary_key: :id,
#       foreign_key: "#{self_class_name.to_s.downcase.underscore}_id".singularize.to_sym,
#       class_name: name.singularize.camelcase
#     }
#
#     defaults.keys.each do |k|
#       if options[k].nil?
#         options[k] = defaults[k]
#       end
#     end
#
#
#     @primary_key = options[:primary_key]
#     @foreign_key = options[:foreign_key]
#     @class_name = options[:class_name]
#
#   end
# end
class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      :foreign_key => "#{self_class_name.underscore}_id".to_sym,
      :class_name => name.to_s.singularize.camelcase,
      :primary_key => :id
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end
module Associatable
  # Phase IIIb

  # def belongs_to(name, options = {})
  #   # ...
  #   options = BelongsToOptions.new(name, options)
  #   result = nil
  #   define_method(name) do
  #     f_key = self.send(options.foreign_key)
  #     # options.model_class.find(f_key)
  #     result = options.model_class.where({id: f_key}).first
  #   end
  #   result
  # end

  def belongs_to(name, options = {})
  self.assoc_options[name] = BelongsToOptions.new(name, options)

  define_method(name) do
    options = self.class.assoc_options[name]

    key_val = self.send(options.foreign_key)
    options
      .model_class
      .where(options.primary_key => key_val)
      .first
  end
end


  # def has_many(name, options = {})
  #   # ...
  #
  # end

  def has_many(name, options = {})
    self.assoc_options[name] =
      HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]

      key_val = self.send(options.primary_key)
      options
        .model_class
        .where(options.foreign_key => key_val)
    end
  end

  # def assoc_options
  #   # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  # end

  def assoc_options
   # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
   @assoc_options ||= {}
   @assoc_options
 end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
