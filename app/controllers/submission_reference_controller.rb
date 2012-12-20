class SubmissionReferenceController < ApplicationController

include ApplicationHelper

  before_filter :is_member_of, :only => [:show, :edit, :destroy]

  layout "submission"
  
  # active_scaffold :reference_author do |config|
  #   config.list.columns.exclude :submission_reference
  # end


  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify method depricated on Rails 3 - do I need to replicate this functionality?  ???JL
  # verify :method => :post, :only => [ :destroy, :create, :update ],
  #        :redirect_to => { :action => :list }

  def list
		@show_nav_bar = true
		@submission_references = SubmissionReference.find_all_by_submission_id(session[:submiss_id], :order => 'seqnum')
		render(:layout => 'submission')
  end

  def show
    @show_nav_bar = true
    @submission_reference = SubmissionReference.find(params[:id])
  end

  def new
    @edit_new_flag = 'New'
    @show_nav_bar = true
    session[:new_rec_id]   = nil
    session[:reference_id] = nil
    @pub_type_choices = Lookup.get_listbox_choices('submission_references', 'pub_type')
    @submission_reference = SubmissionReference.new
    @field_list = get_html_form_fields('submission_references', @submission_reference, session[:show_help])
		render(:layout => 'submission', :template => 'submission_reference/edit')
  end

  def create
    @submission_reference = SubmissionReference.new(params[:submission_reference])
    # @submission_reference = SubmissionReference.new(params[:field_name] => params[:field_value])
  	@submission_reference.submission_id = session[:submiss_id]
    @submission_reference.save
    session[:new_rec_id]   = @submission_reference.id
    session[:reference_id] = @submission_reference.id
    redirect_to({:action => 'list'})
  end

  def edit
    @edit_new_flag = 'Editing'
    @pub_type_choices = Lookup.get_listbox_choices('submission_references', 'pub_type')
    @show_nav_bar = true
		@submission_reference = SubmissionReference.find(params[:id])
		session[:reference_id] = @submission_reference.id
    @field_list = get_html_form_fields('submission_references', @submission_reference, session[:show_help])
    render(:layout => 'submission')
  end

  def update(my_submission_reference)
    @submission_reference = SubmissionReference.find(my_submission_reference)
    @submission_reference.update_attributes(params[:field_name] => params[:field_value] )
  end


  def save
    @submission_reference = SubmissionReference.find(params[:id])
    @submission_reference.update_attributes(params[:submission_reference] )
    redirect_to({:action => 'show', :id => @submission_reference})
  end


  def destroy
    SubmissionReference.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

	def edit_this(ref_id)
		@show_nav_bar = true
		@submission_reference = SubmissionReference.find(ref_id)
		render(:layout => 'submission', :template => 'submission_reference\edit')
	end

  # def on_field_change
  #   if params[:id]  # if we are updating an existing record params[:id] will not be nil
  #     my_submission_reference = SubmissionReference.find(params[:id])
  #     my_submission_reference.update_attribute(params[:field_name], params[:field_value] )
  #   else  # params[:id] will be nil when creating a new object (as opposed to editing existing)
  #     if session[:reference_id]
  #       my_submission_reference = SubmissionReference.find(session[:reference_id])
  #       my_submission_reference.update_attribute(params[:field_name], params[:field_value] )
  #     else  # we must create a new record
  #       my_submission_reference = SubmissionReference.new(params[:field_name] => params[:field_value])
  #       my_submission_reference.submission_id = session[:submiss_id]
  #       my_submission_reference.save
  #       session[:reference_id] = my_submission_reference.id
  #       # ???JL what should be done if save fails?  9/26/2007 17:28
  #     end
  #   end
  #   render(:nothing => true)
  # end  # on_field_change

  def on_field_change
    super
  end


  private

  def is_member_of
    if SubmissionReference.find_by_id_and_submission_id(params[:id], session[:submiss_id])
      return true
    else
      redirect_to(:controller => 'submission', :action => 'show_my')
      return false
    end
  end


end
