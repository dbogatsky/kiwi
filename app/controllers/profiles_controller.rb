class ProfilesController < ApplicationController

  def show
  end


  def update
    current_user.update_attributes user_params
    redirect_to profile_path
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :title, :avatar, :email, :locale, :time_zone)
  end
end
