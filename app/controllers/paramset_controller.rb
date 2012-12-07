class ParamsetController < ApplicationController
#  before_filter :log_this
include ApplicationHelper

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify :method => :post, :only => [ :destroy, :create, :update ],
  #        :redirect_to => { :action => :list }

  def list
    @paramsets = Paramset.find_all_by_instrument_id(params[:id])
    session[:instrument_id] = params[:id]
    @show_nav_bar = true
    render(:layout => 'submission')
  end

  def show
    @paramset = Paramset.find(params[:id])
    @show_nav_bar = true
    render(:layout => 'submission')
  end

  def new
    session[:new_rec_id] = nil
    @paramset = Paramset.new
    @show_nav_bar = true
    load_listboxes()
    @field_list = get_html_form_fields('paramsets', @paramset, session[:show_help])
    render(:layout => 'submission', :template => 'paramset/edit')
  end

  def create
    @paramset = Paramset.new(params[:field_name] => params[:field_value])
    @paramset.instrument_id = session[:instrument_id]
    @paramset.save
    session[:new_rec_id] = @paramset.id
  end

  def edit
    @paramset = Paramset.find(params[:id])
    @show_nav_bar = true
    load_listboxes()
    @field_list = get_html_form_fields('paramsets', @paramset, session[:show_help])
    render(:layout => 'submission')
  end

  def update(my_paramset)
    @paramset = Paramset.find(my_paramset)
    @paramset.update_attribute(params[:field_name], params[:field_value])
  end

  def destroy
    Paramset.find(params[:id]).destroy
    redirect_to(:action => 'list', :id => session[:instrument_id])
  end

  def load_listboxes
    @technique_choices = Lookup.get_listbox_choices('paramsets', 'technique')
    @excitation_source_label_choices     = Lookup.get_listbox_choices('paramsets', 'excitation_source_label')
    @excit_src_strength_unit_choices     = Lookup.get_listbox_choices('paramsets', 'excit_src_strength_unit')
    @excit_src_strength_unit_choices     = Lookup.get_listbox_choices('paramsets', 'excit_src_strength_unit')
    @analyzer_resolution_unit_choices    = Lookup.get_listbox_choices('paramsets', 'analyzer_resolution_unit')
    @pass_energy_retard_rat_unit_choices = Lookup.get_listbox_choices('paramsets', 'pass_energy_retard_rat_unit')
    @analyzer_constant_width_choices     = Lookup.get_listbox_choices('paramsets', 'analyzer_constant_width')
    @ang_accept_constant_width_choices   = Lookup.get_listbox_choices('paramsets', 'ang_accept_constant_width')
    @excit_src_raster_flag_choices       = Lookup.get_listbox_choices('paramsets', 'excit_src_raster_flag')

  end

  def on_field_change
    super
  end


end
