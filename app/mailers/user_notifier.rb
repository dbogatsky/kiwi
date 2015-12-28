class UserNotifier < ActionMailer::Base
  default :from => 'noreply@example.com'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_media_email(user)
	attachments['index.jpeg'] = File.read('app/assets/images/index.jpeg')
    mail( :to => user,
    :subject => 'Media File' )
  end
end

