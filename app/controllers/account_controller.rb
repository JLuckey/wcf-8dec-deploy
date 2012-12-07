class AccountController < ApplicationController

  skip_before_filter :check_new, :only => [:login]
	skip_before_filter :authorize, :only => [:login, :signup, :forgot_password, :activate, :reset_password]
	skip_before_filter :check_submiss_status

#  observer :user_observer    # initializes the Observer -- 2/19/2007 18:56 disabled Observer & transferred the 2
                              # callbacks, after_create & after_save to the User model.  This was done so that
                              # I could override callback behavior in decendents of User, RegularUser & InviteeUser.
  layout "submission"

# Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  #before_filter :login_from_cookie

  def index
    session[:arr_instr_info] = []
    session[:submiss_title]  = ''
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end

  def login
    return unless request.post?
    session[:arr_instr_info] = []
    session[:submiss_title]  = ''
    session[:submiss_id]     = ''
    session[:id_and_rev]     = ''
    session[:show_help]      = true

    current_user = User.authenticate(params[:user][:login], params[:user][:password])
   # current_user = User.authenticate(params[:login], params[:password])
    if current_user
       session[:user_role]   = current_user.role
       session[:user_id]     = current_user.id

       if current_user.show_splash == 'N'
         redirect_back_or_default(:controller => 'submission', :action => 'show_my')
       else
         render('account/show_splash')
       end

#      if params[:remember_me] == "1"
#        self.current_user.remember_me
#        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
#      end
    end  #if
  end  #login method


  def save_show_splash()
    u = User.find(session[:user_id])
    u.update_attributes(params[:user])
    u.save
    redirect_to(:controller => 'submission', :action => 'show_my')
  end   #save_show_splash()


  def signup
    @user = RegularUser.new(params[:user])
    return unless request.post?
    @user.save!
    self.current_user = @user
    redirect_back_or_default(:controller => 'account', :action => 'login')
    flash[:notice] = "Thanks for signing up! &nbsp An Account Activation email has been sent to #{@user.email}."
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end  # signup()

  def signup_invitee
    if request.post?
      @user = RegularUser.find_by_activation_code(params[:id])
      if @user.update_attributes(params[:user])
        @user.activate
        # Send registration-confirmation email
#        email = UserNotifier.create_invitee_signup_notification(@user)
#        render(:text => "<pre>" + email.encoded + "</pre>")
        # Show "thanks for signing-up" page w/ link to login page
        render(:layout =>'submission', :action => 'signup_thanks')
      else
        render :action => 'signup'
      end  # if
    else
      @user = RegularUser.find_by_activation_code(params[:id])
      render :action => 'signup'
    end  # if
  end  # signup_invitee()

  def activate
    @user = User.find_by_activation_code(params[:id])
    if @user and @user.activate
      flash[:notice] = "Your account has been activated."
		else
      flash[:notice] = "There was a problem with account activation. Please contact the System Administrator @ DevTeam@PublishInSSS.com "
		end
    redirect_back_or_default(:controller => '/account', :action => 'login')
  end  # activate


  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/account', :action => 'index')
  end


  def forgot_password
    return unless request.post?
    if @user = User.find_by_email(params[:email])
      @user.forgot_password
      @user.save
		  UserNotifier.deliver_forgot_password(@user) if @user.recently_forgot_password?

      flash[:notice] = 'A password reset link has been sent to your email address.'
      redirect_back_or_default(:controller => '/account', :action => 'login')
    else
      flash[:notice] = "That email address is not on file - please re-enter a valid email address."
    end
  end


  def reset_password
		# password reset code must not be blank & must exist
		@user = User.find_by_password_reset_code(params[:id])
		if params[:id].blank? or !@user
  	  flash[:notice] = "Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?)"
			return
		end

    # password cannot be blank
		return unless request.post?
		if params[:password].blank?
			flash[:notice] = "Password must be at least 4 characters"
			return
		end

		# password must match password confirmation
		if (params[:password] == params[:password_confirmation])
			@user.password = params[:password]
      @user.reset_password
      flash[:notice] = @user.save ? "Password reset" : "Password reset failed"
			return
		else
      flash[:notice] = "Passwords don't match"
  		return
    end   # if

#   redirect_back_or_default(:controller => '/account', :action => 'index')

#  	rescue
#  	  logger.error "Invalid Reset Code entered"
#  	  flash[:notice] = "Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?)"
##  	  redirect_back_or_default(:controller => '/account', :action => 'index')
#			render(:action => 'reset_password')
  end


	def change_password()
		raise if params[:id].nil?
		@user = User.find_by_password_reset_code(params[:id])
		raise unless @user
		if params[:password].nil?
      flash[:notice] = "Password may not be blank"
		end
		if (params[:password] == params[:password_confirmation])
			@user.password = params[:password]
			@user.password_reset_code = ''
			@user.save

#			self.current_user = @user 			#for the next two lines to work
#      current_user.password_confirmation = params[:password_confirmation]
#      current_user.password = params[:password]
#      @user.reset_password
#      flash[:notice] = current_user.save ? "Password reset" : "Password not reset"
    else
      flash[:notice] = "Password mismatch"
    end   # if
    redirect_back_or_default(:controller => '/account', :action => 'change_password/' + params[:id])
  	rescue
  	  logger.error "Invalid Reset Code entered"
  	  flash[:notice] = "Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?)"
  	  redirect_back_or_default(:controller => '/account', :action => 'change_password/' + params[:id])

	end  # change_password()


end
