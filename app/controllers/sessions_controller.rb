class SessionsController < ApplicationController
  
  def new
  	@title = 'Sign in'
  end

  def create
    @title = 'Sign in'
    user = User.authenticate(params[:session][:email], 
                             params[:session][:password])
    if user.nil?
      flash.now[:error] = "Flash: Invalid email/password"
      render 'new'
    else 
      #handle sccessful login
      sign_in(user)
      redirect_to user_path(user)
    end    

  end

  def destroy
  	sign_out
    redirect_to root_path
  end

 

end
