json.array!(@cloud_applications) do |cloud_application|
  json.extract! cloud_application, :id
  json.url cloud_application_url(cloud_application, format: :json)
end
