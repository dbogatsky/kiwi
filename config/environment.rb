# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Configure smtp settings.
ActionMailer::Base.smtp_settings = {
  :user_name => 'chandel.annie5@gmail.com',
  :password => 'ztech@44',
  :domain => 'test.com',
  :address => 'smtp.gmail.com',
  :port => 465,
  :authentication => :plain,
  :enable_starttls_auto => true
}

