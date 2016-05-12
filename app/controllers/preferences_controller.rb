class PreferencesController < ApplicationController
  def show
    # @current_user = User.find(current_user.id, reload: true)
  end

  def update
    # current_user.update_attributes(request: :update, user: user_params, reload: true)

    flash[:success] = 'Your preference has been successfully updated!'
    redirect_to preference_path
  end

  private

  def user_params
    # params.require(:user).permit(:first_name, :last_name, :title, :avatar, :locale, :time_zone, :role_ids, addresses_attributes: [:id, :street_address, :postcode, :city, :latitude, :longitude, :region, :country], contacts_attributes: [:id, :type, :name, :value])
  end
end
