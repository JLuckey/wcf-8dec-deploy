class AnalysisMethodController < ApplicationController

include ApplicationHelper

  before_filter :is_member_of, :only => [:destroy]

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify :method => :post, :only => [ :destroy, :create, :update ],
  #        :redirect_to => { :action => :list }

#  def list
#    @analysis_method_pages, @analysis_methods = paginate :analysis_methods, :per_page => 10
#  end

  def show
    @analysis_method = AnalysisMethod.find_by_submission_id(session[:submiss_id])
    @show_nav_bar = true
    render(:layout => 'submission')
  end

  def new
    session[:new_rec_id] = nil
    @analysis_method = AnalysisMethod.new
    @show_nav_bar = true
    @field_list = get_html_form_fields('analysis_methods', @analysis_method, session[:show_help])
    render(:layout => 'submission')
  end

  def create
    @analysis_method = AnalysisMethod.new(params[:field_name] => params[:field_value] )
    @analysis_method.submission_id = session[:submiss_id]
    @analysis_method.save
    session[:new_rec_id] = @analysis_method.id
#      flash[:notice] = 'AnalysisMethod was successfully created.'
#      redirect_to :action => 'show'
#    else
#      render :action => 'new'
#    end
  end

  def edit
    @analysis_method = AnalysisMethod.find_by_submission_id(session[:submiss_id])
    @show_nav_bar = true
    @field_list = get_html_form_fields('analysis_methods', @analysis_method, session[:show_help])
    render(:layout => 'submission')
  end

  def update(my_am)
    @analysis_method = AnalysisMethod.find(my_am)
    @analysis_method.update_attribute(params[:field_name], params[:field_value] )
  end

  def destroy
    AnalysisMethod.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def on_field_change
    super
  end


  private

  def is_member_of
    if AnalysisMethod.find_by_id_and_submission_id(params[:id], session[:submiss_id])
      return true
    else
      redirect_to(:controller => 'submission', :action => 'show_my')
      return false
    end
  end


end
