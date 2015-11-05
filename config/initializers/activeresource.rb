if Rails.env.development? or Rails.env.test?
  active_resource_logger = Logger.new('log/active_resource.log', 'daily'); 
  active_resource_logger.level = Rails.env.dev? ? Logger::DEBUG : Logger::INFO;
  HttpLogger.logger = active_resource_logger # defaults to Rails.logger if Rails is defined
  HttpLogger.colorize = true # Default: true
  HttpLogger.ignore = [/newrelic\.com/]
  HttpLogger.log_headers = true  # Default: false
  HttpLogger.log_request_body  = true  # Default: true
  HttpLogger.log_response_body = true  # Default: true
  HttpLogger.level = :info # Desired log level as a symbol. Default: :debug
end
