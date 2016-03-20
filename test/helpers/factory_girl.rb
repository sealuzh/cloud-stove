require 'json'
module FactoryHelpers
  def self.hash_from_json(filename)
    file = File.read(Rails.root + 'test/fixtures/factories' + filename)
    JSON.parse(file)
  end
end
