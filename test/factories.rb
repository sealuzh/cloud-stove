require_relative 'helpers/factory_girl'
FactoryGirl.define do

  factory :user do
    sequence(:email) { |n| "stove_user#{n}@example.com" }
    password '12345678'
    trait :admin do
      is_admin true
    end
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

    factory :rails_app do
      name 'Rails app with Postgres backend'
      user
      after(:create) do |rails_app|
        create(:ingredient, name: 'Postgres', parent: rails_app, user: rails_app.user)
        create(:ingredient, name: 'Rails app', parent: rails_app, user: rails_app.user)
        create(:ingredient, name: 'NGINX', parent: rails_app, user: rails_app.user)
      end
    end
  end

  factory :deployment_recommendation do
    status 'satisfiable'
    num_simultaneous_users 200
    association :ingredient, factory: :rails_app
    after(:create) do |recommendation|
      children = recommendation.ingredient.children
      c2 = create(:resource, :amazon_c2)
      c3 = create(:resource, :amazon_c3)
      more_attributes = {}
      more_attributes['ingredients'] = {
          children[0].id => c2.resource_code,
          children[1].id => c3.resource_code,
          children[2].id => c2.resource_code,
      }
      more_attributes['regions'] = [c2.region_code, c3.region_code, c2.region_code]
      more_attributes['vm_cost'] = '52.08'
      more_attributes['total_cost'] = '52080'
      recommendation.more_attributes = more_attributes
      recommendation.save!
    end
  end

  factory :ram_workload do
    ram_mb_required 1000
    ram_mb_required_user_capacity 100
    ram_mb_growth_per_user 0.5
  end

  factory :cpu_workload do
    cspu_user_capacity 400
    parallelism 0.75
  end

  factory :constraint do
    association :ingredient, factory: :ingredient
  end

  factory :preferred_region_area_constraint do
    preferred_region_area 'EU'
  end

  factory :ram_constraint do
    min_ram 2000
  end

  factory :cpu_constraint do
    min_cpus 2
  end

  factory :dependency_constraint do
    association :source, factory: :ingredient
    association :target, factory: :ingredient
  end

  factory :provider do
    sequence(:name) { |n| "Provider#{n}"}

    factory :amazon_provider do
      name 'Amazon'
      more_attributes FactoryHelpers::hash_from_json('provider-amazon.json')
      after(:create) do |amazon_provider|
        region = 'eu-west-1'
        region_area = 'EU'
        amazon_provider.resources = [
            create(:resource, :amazon_c1, region: region, region_area: region_area, provider: amazon_provider),
            create(:resource, :amazon_c2, region: region, region_area: region_area, provider: amazon_provider),
            create(:resource, :amazon_c3, region: region, region_area: region_area, provider: amazon_provider),
        ]
        amazon_provider.save
      end
    end

    factory :azure_provider do
      name 'Microsoft Azure'
      more_attributes FactoryHelpers::hash_from_json('provider-azure.json')
      after(:create) do |amazon_provider|
        region = 'usgov-virginia'
        region_area = 'US'
        amazon_provider.resources = [
            create(:resource, :azure_c1, region: region, region_area: region_area, provider: amazon_provider),
            create(:resource, :azure_c2, region: region, region_area: region_area, provider: amazon_provider),
            create(:resource, :azure_c3, region: region, region_area: region_area, provider: amazon_provider),
            create(:resource, :azure_c4, region: region, region_area: region_area, provider: amazon_provider),
        ]
        amazon_provider.save
      end
    end

    factory :google_provider do
      name 'Google'
      more_attributes FactoryHelpers::hash_from_json('provider-google.json')
      after(:create) do |google_provider|
        region = 'europe-west1-b'
        region_area = 'EU'
        google_provider.resources = [
            create(:resource, :google_c1, region: region, region_area: region_area, provider: google_provider),
            create(:resource, :google_c2, region: region, region_area: region_area, provider: google_provider),
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
    region 'eu-central-1'
    association :provider, factory: :amazon_provider

    trait :amazon_c1 do
      name 't2.nano'
      more_attributes(JSON.parse '{"cores":"0.05","mem_gb":"0.5","price_per_hour":"0.0065"}')
    end
    trait :amazon_c2 do
      name 't2.micro'
      more_attributes(JSON.parse '{"cores":"0.1", "mem_gb":"1.0", "price_per_hour":"0.013"}')
    end
    trait :amazon_c3 do
      name 'c3.2xlarge'
      more_attributes(JSON.parse '{"cores":"8", "mem_gb":"15.0", "price_per_hour":"0.42"}')
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

    # Good and cheap
    trait :azure_c0 do
      name 'Ax'
      more_attributes(JSON.parse '{"cores":"16","mem_gb":"32","price_per_hour":0.002,"regions":{"japan-east":0.024,"japan-west":0.021,"canada-central":0.024,"canada-east":0.022,"brazil-south":0.024,"australia-southeast":0.029,"australia-east":0.029,"central-india":0.02,"south-india":0.018,"west-india":0.024,"usgov-virginia":0.018,"usgov-iowa":0.018}}')
    end
    trait :azure_c1 do
      name 'A0'
      more_attributes(JSON.parse '{"cores":"1","mem_gb":"0.75","price_per_hour":0.024,"regions":{"japan-east":0.024,"japan-west":0.021,"canada-central":0.024,"canada-east":0.022,"brazil-south":0.024,"australia-southeast":0.029,"australia-east":0.029,"central-india":0.02,"south-india":0.018,"west-india":0.024,"usgov-virginia":0.018,"usgov-iowa":0.018}}')
    end
    trait :azure_c2 do
      name 'A1'
      more_attributes(JSON.parse '{"cores":"1","mem_gb":"1.75","price_per_hour":0.095,"regions":{"us-west-2":0.085,"us-west-central":0.085,"japan-east":0.106,"japan-west":0.095,"canada-central":0.102,"canada-east":0.094,"brazil-south":0.11,"australia-southeast":0.113,"australia-east":0.113,"central-india":0.098,"south-india":0.088,"west-india":0.113,"usgov-virginia":0.083,"usgov-iowa":0.083}}')
    end
    trait :azure_c3 do
      name 'A2'
      more_attributes(JSON.parse '{"cores":"2","mem_gb":"3.5","price_per_hour":0.204,"regions":{"us-west-2":0.17,"us-west-central":0.17,"japan-east":0.212,"japan-west":0.19,"canada-central":0.204,"canada-east":0.187,"brazil-south":0.22,"australia-southeast":0.226,"australia-east":0.226,"central-india":0.197,"south-india":0.177,"west-india":0.226,"usgov-virginia":0.166,"usgov-iowa":0.166}}')
    end
    trait :azure_c4 do
      name 'A3'
      more_attributes(JSON.parse '{"cores":"4","mem_gb":"7","price_per_hour":0.34,"regions":{"us-west-2":0.34,"us-west-central":0.34,"japan-east":0.424,"japan-west":0.38,"canada-central":0.408,"canada-east":0.374,"brazil-south":0.44,"australia-southeast":0.452,"australia-east":0.452,"central-india":0.393,"south-india":0.354,"west-india":0.452,"usgov-virginia":0.332,"usgov-iowa":0.332}}')
    end

    trait :google_c1 do
      name 'f1-micro'
      more_attributes(JSON.parse '{"price_per_hour":0.009,"price_per_month":"4.6872","cores":"0.1","mem_gb":"0.6"}')
    end
    trait :google_c2 do
      name 'g1-small'
      more_attributes(JSON.parse '{"price_per_hour":0.03,"price_per_month":"15.624","cores":"0.5","mem_gb":"1.7"}')
    end
    trait :google_s1 do
      name 'CP-BIGSTORE-STORAGE'
      more_attributes(JSON.parse '{"price_per_month_gb":0.026}')
      resource_type 'storage'
    end
  end
end
