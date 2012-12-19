class UserController < ApplicationController

  before_filter :is_member_of, :only => [:show, :list, :destroy, :remove_user_from_submission]
	skip_before_filter :check_submiss_status
  layout "submission"

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :destroy, :create, :update ],
#         :redirect_to => { :action => :list }

  def list
    @user_pages, @users = paginate :users, :per_page => 10
  end

  def show
    @user = User.find(params[:id])
    @show_nav_bar = true
    render(:layout => 'submission', :action => 'show')
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(session[:user_id])
  end

  def update
    @user = User.find(params[:id])

    params[:user].each do |k, v|
      @user.update_attribute(k, v)
    end
    redirect_to :action => 'show', :id => @user

    # if @user.update_attributes(params[:user])            # update_attributes causes validations to execute which is causing 
    #   flash[:notice] = 'User was successfully updated.'  # probs when fields that are not updated from the User edit screen
    #   redirect_to :action => 'show', :id => @user        # are validated when we dont want them to be.
    # else
    #   render :action => 'edit'
    # end

  end


  # System Admin only allowed to do this
  def destroy
    User.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
# ------------------------------------------------------

  # need code to allow only Submission Admin or System Admin to do this
  def remove_user_from_submission
    SubmissUser.delete_all('user_id = ' + params[:id] + ' and submission_id = ' + session[:submiss_id])
    redirect_to(:controller => 'submission', :action => 'list_users')
  end

  private

  def is_member_of
    if session[:user_role] == 'admin'
      return true
    else
      redirect_to(:controller => 'submission', :action => 'show_my')
      return false
    end
  end

end
