class KeywordController < ApplicationController

include ApplicationHelper

  respond_to :html, :js

  # before_filter :is_member_of, :only => [:show, :edit, :destroy, :update]

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify :method => :post, :only => [ :destroy, :create, :update ],
  #        :redirect_to => { :action => :list }

  def list
    @keywords = Keyword.find_all_by_submission_id(session[:submiss_id], :order => 'seqnum')
    @show_nav_bar = true
    render(:layout => 'submission')
  end

  def show
    @keyword = Keyword.find(params[:id])
  end

  def new
    @mode = 'new_keyword'
    @keyword_rec = Keyword.new
    respond_with(@keyword_rec) 
    # render(:partial => 'keywords_entry')
  end

  def create
    @keyword = Keyword.new(params[:keyword_rec])
    @keyword.submission_id = session[:submiss_id]
    if @keyword.save
#      flash[:notice] = 'Keyword was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @keyword_rec = Keyword.find(params[:id])
    respond_with(@keyword_rec) 
    # render(:partial => 'keywords_entry')
    # render('keywords_entry_main')

  end

  def update
    @keyword_rec = Keyword.find(params[:id])
    if @keyword_rec.update_attributes(params[:keyword_rec])
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Keyword.find(params[:id]).destroy
    redirect_to :action => 'list'
  end


  private

  def is_member_of
    if Keyword.find_by_id_and_submission_id(params[:id], session[:submiss_id])
      return true
    else
      redirect_to(:controller => 'submission', :action => 'show_my')
      return false
    end
  end

end
