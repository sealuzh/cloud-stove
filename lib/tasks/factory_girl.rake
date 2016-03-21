# Recommended way to lint factories to avoid performance overhead if running few tests
# https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md#linting-factories
# Usage: `rake factory_girl:lint`
namespace :factory_girl do
  desc 'Verify that all FactoryGirl factories are valid'
  task lint: :environment do
    if Rails.env.test?
      begin
        DatabaseCleaner.start
        FactoryGirl.lint
      ensure
        DatabaseCleaner.clean_with :transaction
      end
    else
      system("bundle exec rake factory_girl:lint RAILS_ENV='test'")
    end
  end
end
