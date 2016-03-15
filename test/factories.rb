FactoryGirl.define do
  factory :blueprint do
    sequence(:name) { |n| "blueprint#{n}"}
    sequence(:body) { |n| "# blueprint body#{n}" }
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
    sequence(:name) { |n| "component#{n}" }
    component_type 'application-server'
    sequence(:body) { |n| "# component body#{n}" }
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

  factory :deployment_rule do
    more_attributes '{"when x users":"then y servers"}'
  end
end
