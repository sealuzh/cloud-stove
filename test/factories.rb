require_relative 'helpers/factory_girl'
FactoryGirl.define do
  factory :dependency_constraint do
    association :source, factory: :ingredient
    association :target, factory: :ingredient
  end

  factory :constraint do
    association :ingredient, factory: :ingredient
  end

  factory :ingredient do
    sequence(:name) { |n| "Ingredient#{n}" }
    sequence(:body) { |n| "# Ingredient body#{n} with lots of info about this app type." }
    more_attributes '{}'
    template nil
    parent nil

    trait :template do
      is_template true
    end
  end


  factory :provider do
    sequence(:name) { |n| "Provider#{n}"}

    factory :amazon_provider do
      name 'Amazon'
      more_attributes FactoryHelpers::hash_from_json('provider-amazon.json')
      after(:create) do |amazon_provider|
        amazon_provider.resources = [
            create(:resource, :amazon_c1, provider: amazon_provider),
            create(:resource, :amazon_c2, provider: amazon_provider),
            create(:resource, :amazon_s1, provider: amazon_provider),
            create(:resource, :amazon_s2, provider: amazon_provider),
        ]
        amazon_provider.save
      end
    end

    factory :azure_provider do
      name 'Microsoft Azure'
      more_attributes FactoryHelpers::hash_from_json('provider-azure.json')
    end

    factory :google_provider do
      name 'Google'
      more_attributes FactoryHelpers::hash_from_json('provider-google.json')
      after(:create) do |google_provider|
        google_provider.resources = [
            create(:resource, :google_c1, provider: google_provider),
            create(:resource, :google_c2, provider: google_provider),
            create(:resource, :google_s1, provider: google_provider),
        ]
        google_provider.save
      end
    end

    factory :joyent_provider do
      name 'Joyent'
      more_attributes FactoryHelpers::hash_from_json('provider-joyent.json')
    end

    factory :rackspace_provider do
      name 'Rackspace'
      more_attributes FactoryHelpers::hash_from_json('provider-rackspace.json')
    end
  end

  factory :resource do
    sequence(:name) { |n| "Resource#{n}"}
    resource_type 'compute'

    trait :amazon_c1 do
      name 't2.nano'
      more_attributes(JSON.parse '{"cores":"1","mem_gb":"0.5","price_per_hour":"0.0065"}')
    end
    trait :amazon_c2 do
      name 't2.micro'
      more_attributes(JSON.parse '{"cores":"1", "mem_gb":"1.0", "price_per_hour":"0.013"}')
    end
    trait :amazon_s1 do
      name 'storage'
      more_attributes(JSON.parse '{"price_per_gb":"0.0300"}')
      resource_type 'storage'
    end
    trait :amazon_s2 do
      name 'infrequentAccessStorage'
      more_attributes(JSON.parse '{"price_per_gb":"0.0125"}')
      resource_type 'storage'
    end

    trait :google_c1 do
      name 'f1-micro'
      more_attributes(JSON.parse '{"price_per_hour":0.009,"price_per_month":"4.6872","cores":"shared","mem_gb":"0.6"}')
    end
    trait :google_c2 do
      name 'g1-small'
      more_attributes(JSON.parse '{"price_per_hour":0.03,"price_per_month":"15.624","cores":"shared","mem_gb":"1.7"}')
    end
    trait :google_s1 do
      name 'CP-BIGSTORE-STORAGE'
      more_attributes(JSON.parse '{"price_per_month_gb":0.026}')
      resource_type 'storage'
    end
  end

end
