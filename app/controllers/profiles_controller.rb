class ProfilesController < ApplicationController

  def show
    @current_user = User.find(current_user.id, reload: true)
  end

  def update
    current_user.update_attributes(request: :update, user: user_params, reload: true)
    save_avatar
    flash[:success] = 'Your profile has been successfully updated!'
    redirect_to profile_path
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :title, :avatar, :locale, :time_zone, :role_ids, addresses_attributes: [:id, :street_address, :postcode, :city, :latitude, :longitude, :region, :country], contacts_attributes: [:id, :type, :name, :value])
    end

    def save_avatar
      if params[:user][:avatar]
        puts "sending avatar..."
        url = URI.parse("#{RequestStore.store[:api_url]}/users/#{current_user.id}")
        #req = Net::HTTP::Put::Multipart.new url.path,  account: { :avatar => UploadIO.new(File.new(params[:avatar].tempfile), "image/jpeg", "image.jpg")}
        req = Net::HTTP::Put::Multipart.new url.path, :avatar => UploadIO.new(File.new(params[:user][:avatar].tempfile), "image/jpeg", "image.jpg")
        req.add_field("Authorization", "Token token=\"#{RequestStore.store[:user_token]}\", app_key=\"#{APP_CONFIG['api_app_key']}\"")
        #req.add_field("Content-Type", "application/json")
        res = Net::HTTP.start(url.host, url.port) do |http|
          http.request(req)
        end
      end
    end
end
