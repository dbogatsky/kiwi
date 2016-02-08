class MediaController < ApplicationController
	skip_before_filter :verify_authenticity_token, :only => [:create_folder, :save_folder, :destroy, :destroy_multiple, :show, :email_file, :rename_media_file]
  before_action :get_token
  before_action :get_api_values, only: [:index, :show, :save_folder,
                                        :email_file, :rename_media_file,
                                        :upload_file
                                       ]

  # Display all folders
	def index
    if request.format.html?
      @medias = Media.all
      @apiURL = APP_CONFIG['api_url'] + '/download/media'
    else
      render text: 'Not an html request'
    end
 	end

  # Display all media inside of a folder
	def show
    if(request.xhr?)
      if params[:folder_id].present?
        id = params[:folder_id]
        @medias = Media.all(params: {folder_id: id})
      else
        @medias = Media.all
      end
      apiURL = APP_CONFIG['api_url'] + '/download/media'
      mediaArray = []
      @medias.each do |media|
        if media.image?
          cdn_url = media.urls.attributes['thumb']
          media.cdn_url = cdn_url
        else
          apiFullUrl = apiURL + "/" +  media.uid
          curlRes = `curl -X GET -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" "#{apiFullUrl}"`
          curlRes = JSON.parse(curlRes);
          media.cdn_url =curlRes['cdn_url']
        end
        # uid = media.uid
        # apiFullUrl = apiURL + "/" +  media.uid + "?style=thumb"
        # curlRes = `curl -X GET -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" "#{apiFullUrl}"`
        # curlRes = JSON.parse(curlRes);
        # media.cdn_url =curlRes['cdn_url']
        # media.uid = uid
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
      apiURL = APP_CONFIG['api_url'] + '/download/media'
      id = params[:id]
      apiFullUrl = apiURL + "/" +  id;
      new_name = params[:name]
      #curlRes = `curl -X GET -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" "#{apiFullUrl}"`
      curlRes = `curl -X PUT -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -d '{"medium":{"name": "#{new_name}"}}' '#{apiFullUrl}'`
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

    apiURL = APP_CONFIG['api_url'] + '/download/media'
    mediaArray = []
    #attachments = params[:attachments]
    attachments = params[:attachments].split(",")
    attachments.each do | media |
      uid = media
      apiFullUrl = apiURL + "/" +  uid;
      curlRes = `curl -X GET -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" "#{apiFullUrl}"`
      curlRes = JSON.parse(curlRes);
      mediaArray.push(curlRes['cdn_url'])
    end
    #abort(mediaArray.inspect)

    if(to.blank? == true)
      message = 'Please enter email address'
    else
      UserNotifier.send_media_email(to,subject,message, mediaArray).deliver
      message = 'Email has been sent'
    end
    flash[:notice] = message
    redirect_to "/media"
  end

  # rename media file
  def rename_media_file
    if(request.xhr?)
      apiURL = APP_CONFIG['api_url'] + '/download/media'
      id = params[:id]
      apiFullUrl = apiURL + "/" +  id;
      new_name = params[:name]
      #curlRes = `curl -X GET -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" "#{apiFullUrl}"`
      curlRes = `curl -X PUT -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" -H "Content-Type: application/json"  -d '{"medium":{"name": "#{new_name}"}}' '#{apiFullUrl}'`
      render :text => (1 ? 1 : 0) and return
    end
  end
  # Upload file on the server
	def upload_file
    name = params[:media][:payload].original_filename
    filename = params[:filename]
    folderId = params[:folder_id]
    directory = "public/assets/images"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(params[:media][:payload].read) }
    serverPath = '@' + path;
    content_type = params[:media][:payload].content_type

    if(content_type == 'image/png' || content_type == 'image/gif' || content_type == 'image/jpg' || content_type == 'image/jpeg')
      type = 'image'
    elsif (content_type == "application/force-download" || content_type == 'application/pdf' || content_type == 'application/vnd.ms-excel' || content_type == 'application/vnd.ms-excel' || content_type == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || content_type == 'application/msword' || content_type == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' || content_type == 'text/plain')
      type = 'document'
    elsif (content_type == 'audio/mpeg' || content_type == 'audio/x-mpeg' || content_type == 'audio/mp3' || content_type == 'audio/x-mp3' || content_type == 'audio/mpeg3' || content_type == 'audio/x-mpeg3' || content_type == 'audio/mpg' || content_type == 'audio/x-mpg' || content_type == 'audio/x-mpegaudio')
      type = 'audio'
    end
    apiURL = APP_CONFIG['api_url'] + '/media' #http://api.convo.code10.ca/api/v1/media/
    curlRes = `curl -X POST -F"medium[payload]=#{serverPath};type=#{content_type}" -F"type=#{type}" -F"medium[name]=#{filename}" -F"medium[parent_id]=#{folderId}" -H "Authorization: Token token="#{@token}", email="#{@email}", app_key="#{@appKey}"" "#{apiURL}" -v`;
    #abort(curlRes.inspect)
    message = ''
    if curlRes == nil
      message = 'File is not uploaded'
    else
      curlRes = JSON.parse(curlRes);
      if curlRes['payload_content_type'] != nil and curlRes['payload_content_type'][0] == "is Fnvalid"
        message = 'File is not uploaded'
      else
        message = 'File is uploaded'
        File.delete(path)
      end
    end
    flash[:notice] = message
    redirect_to "/media"
  end

  # Used to download the media file
  def download_file
    require 'open-uri'
    url = params[:url]
    uri = URI.parse(params[:url])
    filename = params[:name]+ File.extname(uri.path)
    data = open(url).read
    send_data data, disposition: 'attachment', filename: filename
  end

  private
    def get_token
      #set gloal var for token to be used in model, hack for now
      $user_token = session[:token]
    end

    def resource_params
      params.permit( :id, :name, :type, :folder_id)
    end

    def get_api_values
      @email = current_user.email
      @appKey = APP_CONFIG['api_app_key']
      @token = session[:token]
    end

end
