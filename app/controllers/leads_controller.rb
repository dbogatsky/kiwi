class LeadsController < ApplicationController
  load_and_authorize_resource except: [:get_users]

  def index
  end

  def new
  end
end
