json.array!(@components) do |component|
  json.extract! component, :id, :name, :more_attributes
  json.url component_url(component, format: :json)
end
