class ProfilesController < ApplicationController

  def show
  end


  def update
    current_user.update_attributes(request: :update, user: user_params, reload: true)
    save_avatar
    redirect_to profile_path
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :title, :avatar, :locale, :time_zone, :role_ids, addresses_attributes: [:id, :street_address, :postcode, :city, :region, :country], contacts_attributes: [:id, :type, :name, :value])
    end

    def save_avatar
      if params[:user][:avatar]
        puts "sending avatar..."
        url = URI.parse("#{ENV.fetch("ORCHARD_API_HOST")}/users/#{current_user.id}")
        #req = Net::HTTP::Put::Multipart.new url.path,  account: { :avatar => UploadIO.new(File.new(params[:avatar].tempfile), "image/jpeg", "image.jpg")}
        req = Net::HTTP::Put::Multipart.new url.path, :avatar => UploadIO.new(File.new(params[:user][:avatar].tempfile), "image/jpeg", "image.jpg")
        req.add_field("Authorization", "Token token=\"#{$user_token}\", app_key=\"#{APP_CONFIG['api_app_key']}\"")
        #req.add_field("Content-Type", "application/json")
        res = Net::HTTP.start(url.host, url.port) do |http|
          http.request(req)
        end
      end
    end
end
