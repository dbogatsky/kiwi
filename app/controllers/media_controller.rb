class MediaController < ApplicationController
	skip_before_filter :verify_authenticity_token, :only => [:create_folder, :save_folder, :destroy, :destroy_multiple, :show, :email_file, :rename_media_file]
  before_action :get_token

  # Display all folders
	def index
    @medias = Media.all
 	end
  
  # Display all media inside of a folder
	def show 
    if(request.xhr?)
      id = params[:folder_id]
      @medias = Media.all(params: {folder_id: id})
      email = current_user.email
      appKey = APP_CONFIG['api_app_key']
      token = session[:token]
      apiURL = APP_CONFIG['api_url'] + '/download/media'
      mediaArray = []
      @medias.each do |media|
        uid = media.uid
        apiFullUrl = apiURL + "/" +  media.uid;
        curlRes = `curl -X GET -H "Authorization: Token token="#{token}", email="#{email}", app_key="#{appKey}"" "#{apiFullUrl}"`
        curlRes = JSON.parse(curlRes);
        media.cdn_url =curlRes['cdn_url']
        mediaArray.push(media)
      end
      render json: mediaArray
    end
 	end
  
	# Create a new media folder
	def create_folder
    if(request.xhr?)
      @medias = Media.new(resource_params)
      @medias.type = params[:type]
      @medias.name = params[:name]
      render :text => (@medias.save ? @medias.id : 0) and return
    end
	end
  
  # Edit existing folder
	def save_folder
    if(request.xhr?)
      email = current_user.email
      appKey = APP_CONFIG['api_app_key']
      token = session[:token]
      id = params[:id]
      new_name = params[:name]
      #curlRes = `curl -X GET -H "Authorization: Token token="#{token}", email="#{email}", app_key="#{appKey}"" "#{apiFullUrl}"`
      curlRes = `curl -X PUT -H "Authorization: Token token="#{token}", email="#{email}", app_key="#{appKey}"" -H "Content-Type: application/json"  -d '{"medium":{"name": "#{new_name}"}}' 'http://api.convo.code10.ca/api/v1/media/#{id}'`
      render :text => (1 ? 1 : 0) and return
    end
	end
  
  # Used to delete the media folder
  def destroy
    render :text => (Media.delete(params[:id]) ? 1 : 0) and return
  end
  
  # Used to delete the media files
  def destroy_multiple
    duplicates = params[:ids].split(",")
    duplicates.each do | duplicate |
      Media.delete(duplicate)
    end
    render :text => ( 1 ? 1 : 0) and return
  end
	
  #Email media file
  def email_file
    #abort(.inspect)
    #name = 'testEmail.jpeg'
    #cdnUrl = params[:cdn_url]
    to = params[:to]
    subject = params[:subject]
    message = params[:message]
    #directory = "app/assets/images"
    #path = File.join(directory, name)
    #File.open(path, "wb") { |f| f.write(cdnUrl) }
    #serverPath = '@' + path;
    #require 'open-uri'
    #open('image.jpeg', 'wb') do |file|
      #file.write(cdnUrl)
    #end
    if(to.blank? == true)
      message = 'Please enter email address'
    else
      UserNotifier.send_media_email(to,subject,message).deliver
      message = 'Email has been sent'
    end
    flash[:notice] = message
    redirect_to "/media"
  end
  
  # rename media file
  def rename_media_file
    if(request.xhr?)
      email = current_user.email
      appKey = APP_CONFIG['api_app_key']
      token = session[:token]
      id = params[:id]
      new_name = params[:name]
      #curlRes = `curl -X GET -H "Authorization: Token token="#{token}", email="#{email}", app_key="#{appKey}"" "#{apiFullUrl}"`
      curlRes = `curl -X PUT -H "Authorization: Token token="#{token}", email="#{email}", app_key="#{appKey}"" -H "Content-Type: application/json"  -d '{"medium":{"name": "#{new_name}"}}' 'http://api.convo.code10.ca/api/v1/media/#{id}'`
      render :text => (1 ? 1 : 0) and return
    end
  end
  # Upload file on the server
	def upload_file
    name = params[:media][:payload].original_filename
    filename = params[:filename]
    folderId = params[:folder_id]
    directory = "app/assets/images"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(params[:media][:payload].read) }
    serverPath = '@' + path;
    type = 'image'
    email = current_user.email
    appKey = APP_CONFIG['api_app_key']
    token = session[:token]
    apiURL = APP_CONFIG['api_url'] + '/media' #http://api.convo.code10.ca/api/v1/media/
    curlRes =  `curl -X POST  -F"medium[payload]=#{serverPath}" -F"type=#{type}" -F"medium[name]=#{filename}" -F"medium[parent_id]=#{folderId}" -H "Authorization: Token token="#{token}", email="#{email}", app_key="#{appKey}"" "#{apiURL}"  -v`;
    message = ''
    if curlRes == nil
      message = 'Image is not uploaded'
    else
      curlRes = JSON.parse(curlRes);
      if curlRes['payload_content_type'] != nil and curlRes['payload_content_type'][0] == "is Fnvalid"
        message = 'Image is not uploaded'
      else
        message = 'Image is uploaded'
        File.delete(path)
      end
    end
    flash[:notice] = message
    redirect_to "/media"
  end

  private
  def get_token
    #set gloal var for token to be used in model, hack for now
    $user_token = session[:token]
  end
 
  def resource_params
    params.permit( :id, :name, :type, :folder_id)
  end

end
