json.array!(@blueprints) do |blueprint|
  json.extract! blueprint, :id, :name, :more_attributes
  json.url blueprint_url(blueprint, format: :json)
end
