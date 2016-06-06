require 'test_helper'

class BlueprintStoriesTest < ActionDispatch::IntegrationTest
  test 'list blueprints' do
    n = 5
    create_list(:blueprint, n)
    visit blueprints_path
    assert page.has_content? "Displaying all #{n} blueprints"
  end

  test 'create new blueprint' do
    c1 = build_stubbed(:app_component)
    c2 = build_stubbed(:db_component)
    bp = build_stubbed(:mt_blueprint)

    visit blueprints_path
    assert page.has_content? 'No blueprints found'

    first(:link, 'New Blueprint').click
    fill_in 'Name', with: bp.name
    fill_in 'Body', with: bp.body

    add_component(c1, 1)
    add_component(c2, 2)
    click_button 'Save'

    assert page.has_content? 'Blueprint was successfully created.'
    assert page.has_content? bp.name
    assert page.has_content? c1.name
    # Check Markdown rendering of title header
    assert page.has_xpath?('//section[@class="component"]/h2[text()="Introduction"]')
    assert page.has_content? c2.name
  end

  def add_component(component, n)
    click_link 'Add Component'
    within(:xpath, "//form/div[3]/fieldset[#{component_fieldset(n)}]") do
      fill_in 'Name', with: component.name
      fill_in 'Component type', with: component.component_type
      fill_in 'Body', with: component.body
    end
  end

  def component_fieldset(n)
    (n*2) - 1
  end

  test 'edit blueprint' do
    bp = create(:blueprint, components_count: 2)
    num_components = bp.components.count
    new_name = 'Renamed Blueprint'

    visit blueprint_path(bp)
    click_link 'Edit'
    fill_in 'blueprint_name', with: new_name
    check 'blueprint_components_attributes_0__destroy'
    click_button 'Save'

    new_bp = Blueprint.find(bp.id)
    assert_equal (num_components - 1), new_bp.components.count
    assert page.has_content? 'Blueprint was successfully updated.'
    assert page.has_content? new_name
  end

  test 'destroy blueprint' do
    bp = create(:blueprint)

    visit blueprint_path(bp)
    click_link 'Destroy'
    page.accept_alert

    assert_raises(ActiveRecord::RecordNotFound) { bp.reload }
    assert page.has_content? 'Blueprint was successfully destroyed.'
  end

  # test 'copy blueprint' do
  #   bp = create(:blueprint, components_count: 2)
  #   new_component = build_stubbed(:component)
  #   new_name = 'Cloned blueprint'
  #
  #   visit blueprint_path(bp)
  #   click_link 'Copy'
  #
  #   check 'blueprint_components_attributes_1__destroy'
  #   fill_in 'Name', with: new_name, match: :first
  #   click_button 'Save'
  #
  #   assert page.has_content? 'Blueprint was successfully created.'
  #   assert page.has_content? new_name
  #   new_bp = Blueprint.find_by_name new_name
  #   assert_equal 1, new_bp.components.count
  #   # Updating the new blueprint must not affect the old one
  #   assert_equal 2, bp.components.count
  # end
end
