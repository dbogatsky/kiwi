# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Configure smtp settings.
#ActionMailer::Base.smtp_settings = {
 # :user_name => 'chandel.annie5@gmail.com',
 # :password => 'ztech@44',
 # :domain => 'localhost:3000',
 # :address => 'smtp.gmail.com',
  #:port => 465,
 # :authentication => :plain,
 # :enable_starttls_auto => true
#}

 # config.action_view.raise_on_missing_translations = false
 # config.action_mailer.perform_deliveries = true
 # config.action_mailer.default_url_options = { :host => 'http://pgi.zapbuild.com', :port=> '3052' }
 # config.action_mailer.delivery_method = :smtp
 # config.action_mailer.smtp_settings = {
 #   address:              'smtp.gmail.com',
 #   port:                 587,
 #  user_name:            'rickcastle886@gmail.com',
 #  password:             'ztech@44',
 #  authentication:       'plain',
 #  enable_starttls_auto: true
 #}
