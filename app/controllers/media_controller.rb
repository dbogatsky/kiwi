class MediaController < ApplicationController
	skip_before_filter :verify_authenticity_token, :only => [:create_folder, :save_folder, :destroy, :show]
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
  
  # Used to delete the media folder
  def destroy
    render :text => (Media.delete(params[:id]) ? 1 : 0) and return
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
