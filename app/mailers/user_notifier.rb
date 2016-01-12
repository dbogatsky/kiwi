class UserNotifier < ActionMailer::Base
  default :from => 'noreply@example.com'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_media_email(to,subject,message, mediaArray)
    require 'open-uri'
    path = 'app/assets/images/'
    mediaArray.each do |media|
      uri = URI.parse(media)
      filename =  File.basename(uri.path)
      open(path + filename, 'wb') do |file|
        file << open(media).read
      end
      attachments[filename] = File.read(path + filename)
    end
    @message = message
    mail( :to => to,
    :subject => subject )
  end
end

