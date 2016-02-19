class Admin::AdminController < ApplicationController
  layout 'admin/application'
  # before_action :authenticate_superadmin!

  protected
    # def authenticate_superadmin!
    #   unless superadmin
    #     flash[:danger] = 'Unauthorized Access!'
    #     return redirect_to root_url
    #   end
    # end
end