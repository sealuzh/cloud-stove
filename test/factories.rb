require_relative 'helpers/factory_girl'
FactoryGirl.define do
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

    after(:create) do |rails_cloud_app|
      cc = [create(:concrete_component, :webrick, cloud_application: rails_cloud_app),
            create(:concrete_component, :postgres, cloud_application: rails_cloud_app)]
      rails_cloud_app.concrete_components = cc
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

    trait :sqlite do
      more_attributes '{"availability":{"$gte":"0.999"},"costs":{"$lte":"200","currency":"$","interval":"month"}}'
      concrete_component :sqlite
    end

    trait :nginx do
      more_attributes '{"availability":{"$gte":"0.999"},"costs":{"$lte":"200","currency":"$","interval":"month"}}'
      concrete_component :nginx
    end
  end

  factory :provider do
    sequence(:name) { |n| "Provider#{n}"}

    factory :aws_provider do
      name 'Amazon'
      more_attributes FactoryHelpers::hash_from_json('provider-amazon.json')
    end
  end

  factory :resource do
    sequence(:name) { |n| "Resource#{n}"}
    resource_type 'compute'
  end

  factory :deployment_recommendation do
    # This model initially had no columns defined.
  end
end
