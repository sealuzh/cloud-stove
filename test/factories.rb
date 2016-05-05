require_relative 'helpers/factory_girl'
FactoryGirl.define do
  factory :ingredient do
    name "MyString"
    body "MyText"
    type ""
    more_attributes "MyText"
    template_ingredient nil
    parent_ingredient nil
  end
  factory :blueprint do
    sequence(:name) { |n| "Blueprint#{n}"}
    sequence(:body) { |n| "# Blueprint body#{n} with lots of info about this app type." }

    #blueprint_with_components
    transient do
      components_count 1
    end
    after(:create) do |blueprint, evaluator|
      create_list(:component, evaluator.components_count, blueprint: blueprint)
    end
  end

  factory :mt_blueprint, class: Blueprint do
    name 'Multitier Architecture'
    body  '# Basic Properties
      - Web Frontend
      - Application Server
      - Database Backend'
    components { |c| [c.association(:app_component), c.association(:db_component)] }
  end

  factory :component do
    sequence(:name) { |n| "Component#{n}" }
    component_type 'application-server'
    sequence(:body) { |n| "# Component body#{n} with info about single component" }
    deployment_rule

    factory :app_component do
      name 'Application Server'
      component_type 'application-server'
      body '# Introduction
      Explained at [Wikipedia][1]

      [1]: https://en.wikipedia.org/wiki/Application_server'
      deployment_rule
    end

    factory :db_component do
      name 'Database Server'
      component_type 'database'
      body '# Performance Considerations
      Typically Disk I/O, RAM bound (CPU not as important)'
      deployment_rule
    end

    factory :lb_component do
      name 'Load Balancer'
      component_type 'load-balancer'
      association :blueprint, factory: :mt_blueprint
    end

    factory :cdn_component do
      name 'CDN'
      component_type 'cdn'
      association :blueprint, factory: :mt_blueprint
    end
  end

  factory :deployment_rule do
    more_attributes '{"when x users":"then y servers"}'
  end

  factory :cloud_application do
    sequence(:name) { |n| "Cloud application#{n}"}
    blueprint

    # cloud_application_with_concrete_components
    transient do
      concrete_components_count 1
    end
    after(:create) do |cloud_app, evaluator|
      create_list(:concrete_component, evaluator.concrete_components_count, cloud_application: cloud_app)
    end
  end

  factory :rails_cloud_application, class: CloudApplication do
    name 'Rails Application'
    body  'A traditional wep application, let\'s say a web shop with
      * Rails as the application server
      * PostgreSQL as database'
    association :blueprint, factory: :mt_blueprint

    after(:create) do |rails_cloud_app|
      # Ensure that the back-references are set correctly (e.g., components refer to the same blueprint)
      app_component = rails_cloud_app.blueprint.components.where(name: build_stubbed(:app_component).name).first
      db_component = rails_cloud_app.blueprint.components.where(name: build_stubbed(:db_component).name).first
      webrick_cc = build(:concrete_component, :webrick, component: app_component, cloud_application: rails_cloud_app)
      webrick_slo = create(:slo_set, :webrick, concrete_component: webrick_cc)
      webrick_cc.slo_sets = [webrick_slo]
      webrick_cc.save
      postgres_cc = build(:concrete_component, :postgres, component: db_component, cloud_application: rails_cloud_app)
      postgres_slo = create(:slo_set, :postgres, concrete_component: postgres_cc)
      postgres_cc.slo_sets = [postgres_slo]
      postgres_cc.save
      rails_cloud_app.concrete_components = [webrick_cc, postgres_cc]
      rails_cloud_app.save
    end
  end

  factory :concrete_component do
    sequence(:name) { |n| "ConcreteComponent#{n}"}

    trait :webrick do
      name 'WebRick Application Server'
      body 'Specific things about the Rails app.'
      association :component, factory: :app_component
    end

    trait :postgres do
      name 'PostgreSQL Database'
      body 'Specific things about this postgres db.'
      association :component, factory: :db_component
    end

    trait :sqlite do
      name 'SQLite Database'
      association :component, factory: :db_component
    end

    trait :nginx do
      name 'NginX Load Balancer'
      association :component, factory: :lb_component
    end
  end

  factory :slo_set do
    more_attributes '{ "metric": "availability", "relation": ">=", "value": "0.995" }'
    concrete_component

    trait :webrick do
      more_attributes '{"availability":{"$gte":"0.99"},"costs":{"$lte":"200","currency":"$","interval":"month"}}'
      concrete_component :webrick
    end

    trait :postgres do
      more_attributes '{"availability":{"$gte":"0.999"},"costs":{"$lte":"200","currency":"$","interval":"month"}}'
      concrete_component :postgres
    end

    trait :nginx do
      more_attributes '{"availability":{"$gte":"0.999"},"costs":{"$lte":"200","currency":"$","interval":"month"}}'
      concrete_component :nginx
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

  factory :deployment_recommendation do
    # This model initially had no columns defined.
  end
end
