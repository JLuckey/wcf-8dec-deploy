class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new WECF account'
    @body[:url]  = "http://www.PublishInSSS.com/account/activate/#{user.activation_code}"
#    @body[:url]  = "http://localhost:3000/account/activate/#{user.activation_code}"
#    @body[:url]  = url_for(:controller => 'account', :action => 'activate', :id => "#{user.activation_code}" )
  end

  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://www.PublishInSSS.com/"
  end

  def invitation(user, submissId, invitorId)
    setup_email(user)
    @subject          += 'You have been invited to join a WCF Submission'
    @body[:url]        = "http://www.PublishInSSS.com/account/signup_invitee/#{user.activation_code}"
    @body[:submission] = Submission.find(submissId)   # session[:submiss_id])
    @body[:invitor]    = User.find(invitorId)         # session[:user_id])
  end

  def invitee_signup_notification(user)
    setup_email(user)
    @subject    += 'Your New WCF Account is ready'
    @body[:url]  = "http://www.PublishInSSS.com/account/login"
  end

	def forgot_password(user)
    setup_email(user)
    @subject    += 'Request to change your password'
    @body[:url]  = "http://www.PublishInSSS.com/account/reset_password/#{user.password_reset_code}"
#   @body[:url]  = "http://192.168.1.104:3000/account/reset_password/#{user.password_reset_code}"   # for local testing
  end

  def reset_password(user)
    setup_email(user)
    @subject    += 'Your WCF password has been reset'
  end

	def submiss_sent_to_sss(user, subm, idandrev, subm_status, prior_status_in)
		@recipients  = "Webmaster@PublishInSSS.com"
    @from        = "Webmaster@PublishInSSS.com"
    @subject     = "Surface Science Spectra - Submission #{subm.id} sent to SSS"
    @sent_on     = Time.now
    @body[:user]        = "#{user.first_name} #{user.last_name}"
		@body[:submiss]     = subm
		@body[:id_and_rev]  = idandrev
		@body[:subm_status] = subm_status
		@body[:prior_status]= prior_status_in
	end  # submiss_sent_to_sss()


	def downtime_notice(email)
    @recipients  = "#{email}"
    @from        = "Webmaster@PublishInSSS.com"
    @subject     = "Surface Science Spectra - WCF Down for Maintenance"
    @sent_on     = Time.now

	end  # downtime_notice()


  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "Webmaster@PublishInSSS.com"
    @subject     = "Surface Science Spectra - "
    @sent_on     = Time.now
    @body[:user] = user
  end

end
