class SpectralFeatTblUnitController < ApplicationController

include ApplicationHelper
#  before_filter :is_member_of, :only => [:show, :edit, :destroy]

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify :method => :post, :only => [ :destroy, :create, :update ],
  #        :redirect_to => { :action => :list }

#  def show
#    @specimen = Specimen.find(params[:id])
#    @show_nav_bar = true
#    render(:layout => 'submission')
#  end

  def new
    session[:new_rec_id] = nil
    @edit_new_flag = 'Editing'
    load_listboxes
		@spectral_feat_tbl_unit = SpectralFeatTblUnit.new
    @show_nav_bar = true
		@edit_new_flag = 'New'
    @field_list = get_html_form_fields('spectral_feat_tbl_units', @spectral_feat_tbl_unit, session[:show_help])
    render(:layout => 'submission', :template => 'spectral_feat_tbl_unit/edit')
  end

  def create
    @spectral_feat_tbl_unit = SpectralFeatTblUnit.new( params[:field_name] => params[:field_value] )
    @spectral_feat_tbl_unit.submission_id = session[:submiss_id]
    @spectral_feat_tbl_unit.save
    session[:new_rec_id] = @spectral_feat_tbl_unit.id
    # redirect_to( {:controller => 'spectral_feature', :action => 'list_spect_feat'} )
  end


  def update(my_id)
    @spectral_feat_tbl_unit = SpectralFeatTblUnit.find(my_id)
    # @spectral_feat_tbl_unit.update_attributes(params[:spectral_feat_tbl_unit])
    @spectral_feat_tbl_unit.update_attributes( params[:field_name] => params[:field_value] )
    # redirect_to( {:controller => 'spectral_feature', :action => 'list_spect_feat'} )
  end


	def edit
#    if is_member_of(params[:id])
      @spectral_feat_tbl_unit = SpectralFeatTblUnit.find_by_submission_id(session[:submiss_id])
      load_listboxes
      @edit_new_flag = 'Editing'
      @show_nav_bar  = true
      @field_list 	 = get_html_form_fields('spectral_feat_tbl_units', @spectral_feat_tbl_unit, session[:show_help])
      render(:layout => 'submission')
#    end

  end

  def destroy
    SpectralFeatTblUnit.find(params[:id]).destroy
    redirect_to :controller => 'spectral_feature', :action => 'list_spect_feat'
  end

	def load_listboxes
    @peak_ampl_method_choices 		= Lookup.get_listbox_choices('spectral_feat_tbl_units', 'peak_ampl_method')
    @peak_ampl_unit_choices   		= Lookup.get_listbox_choices('spectral_feat_tbl_units', 'peak_ampl_unit')
    @concentration_unit_choices   = Lookup.get_listbox_choices('spectral_feat_tbl_units', 'concentration_unit')
  end

  def on_field_change
    super
  end


# Laundry List to create controller
#	Create, Update, Delete

#	1. copy edit action code from existing
#	2. set-up load_listboxes
#	3. update lookups table w/ new lookup values
#	4. copy AutoSave code from existing
# 5. update field_masters table
# 6.



# This code relates to an older & now obsolete implementation of Active Scaffold for this data
#   It is now flagged for removal  JL  3/24/2008 11:05

#  def conditions_for_collection
#    if session[:spect_feat_edit_action] == 'spect_feat'
#      ['submission_id = ? and feat_tbl_comment <> \'\' ', session[:submiss_id]]
#    else
#      ['submission_id = ? and calib_tbl_comment <> \'\' ', session[:submiss_id]]
#    end
#  end

end
