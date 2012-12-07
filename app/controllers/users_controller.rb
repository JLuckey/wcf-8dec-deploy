class UsersController < ApplicationController
# touch this file
  def show
  	@user  = User.find(params[:id])
  	@title = @user.last_name
  end

  def new
  	@user  = User.new
  	@title = 'Sign up'
  end

  def create
  	@user = User.new(params[:user])
  	if @user.save
      flash[:success] = "Welcome to the Sample App!"
  		redirect_to user_path(@user)    #, :flash => { :success => "Welcome to the Sammple App!" }
    else		
  		@title = "Sign up"
  		render 'new'
  	end
  	
  end

end
