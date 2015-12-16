class MediaController < ApplicationController
	skip_before_filter :verify_authenticity_token, :only => :create_folder
  before_action :get_token

  # Display all folders
	def index
    @medias = Media.where(:type => 'folder')
 	end
  
	# Create a new media folder
	def create_folder
    if(request.xhr?)
      @medias = Media.new(resource_params)
      @medias.type = params[:type]
      @medias.name = params[:name]
      render :text => (@medias.save ? 1 : 0) and return
    end
	end
	
  # Upload file on the server
	def upload_file
    name = params[:media][:payload].original_filename
    directory = "app/assets/images"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(params[:media][:payload].read) }
    serverPath = '@' + path;
    curlRes =  `curl -X POST  -F"medium[payload]=#{serverPath}" -F"type=image" -F"medium[name]=unnamed" -H "Authorization: Token token="secret_DiRzuhsVFdNZSi1yjhG6", email="test@example.com", app_key="app_LL1zKMy_vLixnHSyyiAB""  'http://api.convo.code10.ca/api/v1/media'  -v`;
    message = ''
    if curlRes == nil
      message = 'Image is not uploaded'
    else
      curlRes = JSON.parse(curlRes);
      if curlRes['payload_content_type'] != nil and curlRes['payload_content_type'][0] == "is invalid"
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
    params.permit(:name)
  end

end
