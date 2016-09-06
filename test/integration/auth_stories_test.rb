require 'test_helper'

class AuthStoriesTest < ActionDispatch::IntegrationTest
  test 'create new user (sign up)' do
    visit new_user_registration_path
    user = build_stubbed(:user)
    within('#new_user') do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      fill_in 'Password confirmation', with: user.password
      click_button 'Sign up'
    end
    assert page.has_content?('Welcome! You have signed up successfully.')
    assert page.has_content?('Finely crafted Cloud Application Deployments')
  end

  test 'login existing user (sign in)' do
    visit new_user_session_path
    user = create(:user)
    within('#new_user') do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      check 'Remember me'
      click_button 'Log in'
    end
    assert page.has_content?('Signed in successfully.')
    assert page.has_content?('Finely crafted Cloud Application Deployments')
  end

  # TODO: Fix issue that Capybara cannot find the signout button:
  # `Capybara::ElementNotFound: Unable to find button "signout_btn_id"`
  # test 'logout (sign out)' do
  #   sign_in create(:user)
  #   click_button('signout_btn_id')
  # end
end