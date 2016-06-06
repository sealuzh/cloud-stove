# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Assign a value from an attribute hash to an ActiveRecord object
def assign_attribute(attribute_name:, object:, attributes:)
  object.send("#{attribute_name}=", attributes[attribute_name])
end

def assign_attributes(attribute_names:, object:, attributes:)
  attribute_names.each do |attribute_name|
    assign_attribute(attribute_name: attribute_name, object: object, attributes: attributes)
  end
end

def assign_name_and_body(to_object:, from_attributes:)
  assign_attributes(
    attribute_names: [ 'name', 'body' ],
    object: to_object,
    attributes: from_attributes
  )
end

def create_ingredient(ingredient_attributes)
  Ingredient.transaction do
    ingredient = Ingredient.find_or_create_by(name: ingredient_attributes['name'])
    assign_name_and_body(to_object: ingredient, from_attributes: ingredient_attributes)
    ingredient.save!

    ingredient_attributes['children'].each do |child_attributes|
      child = ingredient.children.find_or_create_by(
        name: ingredient_attributes['name']
      )
      assign_name_and_body(to_object: child, from_attributes: child_attributes)
      child.save!
    end
  end
end

Base.class_eval do
  class << self; attr_accessor :base_stack_depth; end
  before_save do
    Base.base_stack_depth ||= caller.size
    stack_depth = [ caller.size - Base.base_stack_depth, 0 ].max
    record_properties = self.try(:name)
    record_properties ||= self.more_attributes.to_json
    puts [
      ' ' * stack_depth, '- ', "Saving ", self.class.to_s, ": ", record_properties
    ].join
  end
end

class RaisingHash < Hash
  def initialize(constructor = {})
    if constructor.respond_to?(:to_hash)
      super()
      update(constructor)
    else
      super(constructor)
    end
    self.default_proc = proc do |hash, key|
      raise KeyError.new("key not found: #{key}")
    end
  end
end

Array.class_eval do
  def prepare_hashes
    map(&:deep_stringify_keys!).map { |h| RaisingHash.new(h) }
  end
end

SEEDS_ROOT = Rails.root + 'db/seeds/'

def load_seed(file_name, context = binding)
  file_path = [ '', '.yml', '.yaml' ].map do |ext|
    path = SEEDS_ROOT + "#{file_name}#{ext}"; path if path.exist?
  end.compact.first
  raise ArgumentError.new "Cannot find file for #{file_name}" unless file_path
  YAML.load(ERB.new(File.read(file_path)).result(context))
end

multitier_template = load_seed('ingredient_template_multitier')
batch_template = load_seed('ingredient_template_batch_processing')

# Create Blueprints
[
  multitier_template,
  batch_template,
].prepare_hashes.each do |attributes|
  create_ingredient(attributes)
end

rails_app_instance = load_seed('ingredient_instance_rails_app', binding)
media_transcoding_instance = load_seed('ingredient_instance_media_transcoding', binding)

[
  rails_app_instance,
  media_transcoding_instance,
].prepare_hashes.each do |attributes|
  create_ingredient(attributes)
end

# Update provider resources if we don't have any
if Provider.count.zero?
  # Reset log indent
  Base.base_stack_depth = nil
  # Execute the update job inline. We need the resources to create
  # deployment recommendations in the next step.
  Rails.application.config.active_job.queue_adapter = :inline
  UpdateProvidersJob.perform_later rescue nil
end
