class AdditionalFileController < ApplicationController

  before_filter :is_member_of, :only => [:show, :edit, :destroy, :update]

  layout('submission')
#  show_nav_bar = true   #???JL try to make this global call work


  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify :method => :post, :only => [ :destroy, :create, :update ],
  #        :redirect_to => { :action => :list }

  def list
    @additional_files = AdditionalFile.find_all_by_submission_id(session[:submiss_id])
    @show_nav_bar = true
  end

  def show
    @additional_file = AdditionalFile.find(params[:id])
    @show_nav_bar = true
  end

  def new
    @additional_file = AdditionalFile.new
    @show_nav_bar = true
  end

  def create
    @additional_file = AdditionalFile.new(params[:additional_file])
    @additional_file.submission_id = session[:submiss_id]
    if @additional_file.save
#      flash[:notice] = 'AdditionalFile was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @additional_file = AdditionalFile.find(params[:id])
    @show_nav_bar = true
  end

  def update
    @additional_file = AdditionalFile.find(params[:id])
#    @additional_file.update_attribute('description', params[:description])  # ???JL Why didn't this work?
    @additional_file.update_attributes(params[:additional_file])
#    @test_var_1 = params[:description]
    redirect_to :action => 'list'
  end

  def destroy
    AdditionalFile.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def save_data_file
    @additional_file = AdditionalFile.new(params[:additional_file])   #find(session[:submiss_id])
#    @additional_file.update_attributes(params[:additional_file])
    @additional_file.submission_id = session[:submiss_id]
    @additional_file.save
    @show_nav_bar = true
  end

  private

  def is_member_of
    if AdditionalFile.find_by_id_and_submission_id(params[:id], session[:submiss_id])
      return true
    else
      redirect_to(:controller => 'submission', :action => 'show_my')
      return false
    end
  end


end
