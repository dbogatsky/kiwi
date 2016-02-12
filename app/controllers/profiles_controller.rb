class ProfilesController < ApplicationController

  def show
  end


  def update
    current_user.update_attributes(request: :update, user: user_params, reload: true)
    redirect_to profile_path
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :title, :avatar, :locale, :time_zone, :role_ids, addresses_attributes: [:id, :street_address, :postcode, :city, :region, :country], contacts_attributes: [:id, :type, :name, :value])
    end
end
