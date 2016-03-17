FactoryGirl.define do
  factory :cloud_application do
    sequence(:name) { |n| "CloudApplication#{n}"}
    blueprint
  end

  factory :blueprint do
    sequence(:name) { |n| "Blueprint#{n}"}
    sequence(:body) { |n| "# Blueprint body#{n} with lots of info about this app type." }
    transient do
      component_count 3
    end
    after(:create) do |component, evaluator|
      create_list(:component, evaluator.component_count)
    end
  end

  factory :mt_blueprint, class: Blueprint do
    name 'Multitier Architecture'
    body  '# Basic Properties
      - Web Frontend
      - Application Server
      - Database Backend'
    components { |c| [c.association(:component), c.association(:db_component)] }
  end

  factory :component do
    sequence(:name) { |n| "Component#{n}" }
    component_type 'application-server'
    sequence(:body) { |n| "# Component body#{n} with info about single component" }
    deployment_rule
  end

  factory :app_component, class: Component do
    name 'Application Server'
    component_type 'application-server'
    body '# Introduction
      Explained at [Wikipedia][1]

      [1]: https://en.wikipedia.org/wiki/Application_server'
    deployment_rule
  end

  factory :db_component, class: Component do
    name 'Database Server'
    component_type 'database'
    body '# Performance Considerations
      Typically Disk I/O, RAM bound (CPU not as important)'
    deployment_rule
  end

  factory :lb_component, class: Component do
    name 'Load Balancer'
    component_type 'load-balancer'
    association :blueprint, factory: :mt_blueprint
  end

  factory :cdn_component, class: Component do
    name 'CDN'
    component_type 'cdn'
    association :blueprint, factory: :mt_blueprint
  end

  factory :concrete_component do
    sequence(:name) { |n| "ConcreteComponent#{n}"}

    trait :webrick do
      name 'WebRick Application Server'
      association component: :app_component
      cloud_application
    end

    trait :sqlite do
      name 'SQLite Database'
      association component: :db_component
      cloud_application
    end

    trait :nginx do
      name 'NginX Load Balancer'
      association component: :lb_component
      cloud_application
    end
  end

  factory :deployment_rule do
    more_attributes '{"when x users":"then y servers"}'
  end

  factory :deployment_recommendation do
    # This model initially had no columns defined.
  end

  factory :provider do
    sequence(:name) { |n| "Provider#{n}"}
  end

  factory :resource do
    sequence(:name) { |n| "Resource#{n}"}
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
end
