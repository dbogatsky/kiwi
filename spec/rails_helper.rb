# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda-matchers'


# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#

# Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
# ActiveRecord::Migration.maintain_test_schema!


RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  # config.include Devise::TestHelpers, :type => :controller
  # config.extend ControllerMacros, :type => :controller

  # config.after(:all) do
  #   if Rails.env.test?
  #     FileUtils.rm_rf(Dir["#{Rails.root}/tmp/spec/uploads"])
  #   end
  # end

  # config.infer_base_class_for_anonymous_controllers = false

  # config.order = 'random'
   #config.render_views = true

  config.use_transactional_fixtures = false

  config.formatter = 'documentation'

  Rails.application.routes.default_url_options[:host] = 'localhost:3000'

  # Always render views in controllers; helps find problems rendering views faster
  # config.render_views

  # config.filter_run_excluding enabled: false
  # config.filter_run_excluding integration: true if ENV['SKIP_INTEGRATION']
  config.infer_spec_type_from_file_location!
end
