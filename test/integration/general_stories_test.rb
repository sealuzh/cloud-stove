require 'test_helper'

class GeneralStoriesTest < ActionDispatch::IntegrationTest
  test 'landing page has title text' do
    visit root_path
    assert page.has_content?('Finely crafted Cloud Application Deployments')
  end

  test 'create new application blueprint' do
    c1 = Component.new(name: 'Application Server',
      component_type: 'application-server',
      body: '# Introduction
      Explained at [Wikipedia][1]

      [1]: https://en.wikipedia.org/wiki/Application_server',
      deployment_rule: DeploymentRule.new(more_attributes: '{"when x users":"then y servers"}'))
    c2 = Component.new(name: 'Database Server',
      component_type: 'database',
      body: '# Performance Considerations
      Typically Disk I/O, RAM bound (CPU not as important)',
      deployment_rule: DeploymentRule.new(more_attributes: '{"when x connections":"then y threads"}'))
    bp = Blueprint.new(name: 'Multitier Architecture', body:
      '# Basic Properties
      - Web Frontend
      - Application Server
      - Database Backend',
      components: [c1,c2])

    visit blueprints_path
    assert page.has_content?('No blueprints found')

    first(:link, 'New Blueprint').click
    fill_in('Name', with: bp.name)
    fill_in('Body', with: bp.body)

    add_component(c1, 1)
    add_component(c2, 2)
    click_button 'Save'

    assert page.has_content?('Blueprint was successfully created.')
    assert page.has_content?(bp.name)
    assert page.has_content?(c1.name)
    # Check Markdown rendering of title header
    assert page.has_xpath?('//section[@class="component"]/h2[text()="Introduction"]')
    assert page.has_content?(c2.name)
  end

  def add_component(component, n)
    click_link 'Add Component'
    within(:xpath, "//form/div[3]/fieldset[#{component_fieldset(n)}]") do
      fill_in('Name', with: component.name)
      fill_in('Component type', with: component.component_type)
      fill_in('Body', with: component.body)
    end
  end

  def component_fieldset(n)
    (n*2) - 1
  end

  test "get application list" do
    get cloud_applications_path
    assert_response :success
  end

  test "get blueprints list" do
    get blueprints_path
    assert_response :success
  end

  test "get providers overview" do
    get providers_path
    assert_response :success
  end
end
