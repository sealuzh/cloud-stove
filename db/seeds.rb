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

def create_blueprint(bp_attributes)
  Blueprint.transaction do
    blueprint = Blueprint.find_or_create_by(name: bp_attributes['name'])
    assign_name_and_body(to_object: blueprint, from_attributes: bp_attributes)
    blueprint.save!
  
    bp_attributes['components'].each do |component_attributes|
      component = blueprint.components.find_or_create_by(
        component_type: component_attributes['component_type']
      )
      assign_name_and_body(to_object: component, from_attributes: component_attributes)
      component.save!
      
      deployment_rule = component.deployment_rule || component.build_deployment_rule
      deployment_rule.more_attributes = component_attributes['deployment_rule']
      deployment_rule.save!
    end
  end
end

def create_application_instance(app_instance_attributes)
  CloudApplication.transaction do
    app_instance = CloudApplication.find_or_create_by(name: app_instance_attributes['name'])
    assign_name_and_body(to_object: app_instance, from_attributes: app_instance_attributes)
    app_instance.blueprint_id = app_instance_attributes['blueprint_id']
    app_instance.save!
    
    app_instance_attributes['concrete_components'].each do |concrete_component_attributes|
      concrete_component = app_instance.concrete_components.find_or_create_by(
        component_id: app_instance.blueprint.components.find_by(
          component_type: concrete_component_attributes['component_type']
        ).id
      )
      assign_name_and_body(
        to_object: concrete_component, 
        from_attributes: concrete_component_attributes
      )
      concrete_component.save!
      
      concrete_component.slo_sets.delete_all
      concrete_component_attributes['slo_sets'].each do |slo_attributes|
        concrete_component.slo_sets.create!(more_attributes: slo_attributes)
      end
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


# TODO: Add second blueprint

# Create Blueprints
[
].prepare_hashes.each do |bp_attributes|
  create_blueprint(bp_attributes)
end


# TODO: Add more application instances

[
].prepare_hashes.each do |app_instance_attributes|
  create_application_instance(app_instance_attributes)
end

# TODO: For now, also add deployment recommendation

