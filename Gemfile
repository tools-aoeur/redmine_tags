source 'https://rubygems.org'

gem 'acts-as-taggable-on', '~> 9.0'

# Some gems come from redmine_base_rspec if detected
base_rspec_dir = File.join(__dir__, '../redmine_base_rspec')

group :test, :development do
  unless Dir.exist?(base_rspec_dir)
    gem 'rubocop'
    gem 'rubocop-performance'
    gem 'rubocop-rails'
    gem 'rubocop-rake'
    gem 'rubocop-rspec'
    gem 'rubocop-thread_safety'
  end
end
