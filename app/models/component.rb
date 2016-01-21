class Component < Base
  ma_accessor :body
  belongs_to :blueprint



  def deployments
    @deployments ||= ma['deployments'].map { |d| Deployment.new(d) } rescue []
  end

  def deployments_attributes=(attributes)
    deployments = []
    attributes.each do |_key, value|
      deployments << Deployment.new(value).as_json unless value['_destroy'] == '1'
    end
    ma['deployments'] = deployments
    save!
  end

  class Deployment
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_accessor :id
    attr_accessor :name
    attr_accessor :body
    attr_accessor :_destroy

    def attributes
      { 'name' => nil, 'body' => nil }
    end
  end
end
