class HandleErrorsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue ActionController::BadRequest
    ApplicationController.action(:raise_bad_request).call(env)
  end
end