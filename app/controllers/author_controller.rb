class AuthorController < ApplicationController

include ApplicationHelper

  def index
    list
  end

  def list
    @authors = Author.find_all_by_submission_id(session[:submiss_id], :order => 'seqnum')
    @show_nav_bar = true
    render(:layout => 'submission')
  end

  def show
    @author = Author.find(params[:id])
    if @author.submission_id.to_s == session[:submiss_id]   # For Security purposes.  Verifying that requested Author is a member of current Submission
      @show_nav_bar = true
      render(:layout => 'submission')
    else
      redirect_to(:action => 'index')
      # redirect_to(:action => 'list')
    end

  end

  def new
    # test for submiss id in Session  2/4/2008 12:21 ???JL
    session[:new_rec_id] = nil
    @author = Author.new
    @show_nav_bar = true
    @edit_new_flag = 'New'
    @corresponding_author_choices = Lookup.get_listbox_choices('authors', 'corresponding_author')
    @spectral_category_choices = @field_list = get_html_form_fields('authors', @author, session[:show_help])
    render(:layout => 'submission', :template => 'author/edit')
  end

  def create
    # @author = Author.new(params[:author])
    @author = Author.new(params[:field_name] => params[:field_value])
    @author.submission_id = session[:submiss_id]
    @author.save
    session[:new_rec_id] = @author.id
    # redirect_to({:action => 'list'})
  end

  def edit
    @author = Author.find(params[:id])
    # if @author.submission_id.to_s == session[:submiss_id]   # For Security purposes.  Verifying that requested Author is a member of current Submission
      @show_nav_bar = true
      @edit_new_flag = 'Editing'
      @corresponding_author_choices = Lookup.get_listbox_choices('authors', 'corresponding_author')
      @field_list = get_html_form_fields('authors', @author, session[:show_help])
      render(:layout => 'submission')
    # else
    #   redirect_to(:action => 'list')
    # end
  end

  def update(author_id)
    # ???JL do we need securtiy here?
    @author = Author.find(author_id) 
    @author.update_attributes( params[:field_name] => params[:field_value] )
    # redirect_to({:action => 'show', :id => @author})
  end

  def del_author
    @author = Author.find(params[:id])
    if @author.submission_id.to_s == session[:submiss_id]   # For Security purposes.  Verifying that requested Author is a member of current Submission
      @author.destroy
    end
    redirect_to :action => 'list'
  end

  def on_field_change
    super
  end

end
