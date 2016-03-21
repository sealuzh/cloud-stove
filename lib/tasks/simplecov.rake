# Usage: `rake test:coverage`
namespace :test do
  task :coverage do
    require 'simplecov'
    Rake::Task['test'].execute
  end
end
