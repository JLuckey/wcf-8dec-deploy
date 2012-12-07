class InstrumentController < ApplicationController

include ApplicationHelper

  before_filter :is_member_of, :only => [:show, :edit, :update, :destroy]

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify :method => :post, :only => [ :destroy, :create, :update ],
  #        :redirect_to => { :action => :list }

  def list
    @instruments  = Instrument.find_all_by_submission_id(session[:submiss_id])
    update_instr_info_in_tv()
    @show_nav_bar = true
    render(:layout => 'submission')
  end

  def show
    @instrument = Instrument.find(params[:id])
    @show_nav_bar = true
    render(:layout => 'submission')
  end

  def new
    session[:new_rec_id] = nil
    load_listboxes()
    @instrument = Instrument.new
    @edit_new_flag = 'New'
    @show_nav_bar = true
    @field_list = get_html_form_fields('instruments', @instrument, session[:show_help])
    render(:layout => 'submission', :template => 'instrument/edit')
  end

  def create
    @instrument = Instrument.new(params[:instrument])
    @instrument.submission_id = session[:submiss_id]
    @instrument.save
    session[:new_rec_id] = @instrument.id
    redirect_to({:action => 'list'})
  end

  def edit
    load_listboxes()
    @show_nav_bar = true
    @edit_new_flag = 'Editing'
    @instrument = Instrument.find(params[:id])
    @field_list = get_html_form_fields('instruments', @instrument, session[:show_help])
    render(:layout => 'submission')
  end

  def update(instrument_id)
    @instrument = Instrument.find(instrument_id)
    @instrument.update_attributes( params[:field_name] => params[:field_value] )
  end

  def destroy
    Instrument.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def load_listboxes()
    @instr_thruput_funct_choices         = Lookup.get_listbox_choices('instruments', 'instr_thruput_funct')
    @analyzer_mode_choices               = Lookup.get_listbox_choices('instruments', 'analyzer_mode')
    @ion_gun_used_flag_choices           = Lookup.get_listbox_choices('instruments', 'ion_gun_used_flag')
    @sputtr_current_measure_meth_choices = Lookup.get_listbox_choices('instruments', 'sputtr_current_measure_meth')
    @analyzer_description_choices        = Lookup.get_listbox_choices('instruments', 'analyzer_description')
    @sputtr_src_current_unit_choices     = Lookup.get_listbox_choices('instruments', 'sputtr_src_current_unit')
    @ion_gun_raster_flag_choices         = Lookup.get_listbox_choices('instruments', 'ion_gun_raster_flag')
    @ion_gun_used_flag_choices           = Lookup.get_listbox_choices('instruments', 'ion_gun_used_flag')
  end

  def on_field_change
    super
  end

  def list_existing
    @instrument_list = Instrument.find_by_sql("select su.submission_id, s.title, s.created_on, i.id, i.manufacturer, i.model, i.instrument_name " +
                                              " from submiss_users su, submissions s, instruments i "                                             +
                                              " where su.user_id = #{session[:user_id]} "                                                                            +
                                              " and su.submission_id = s.id "                                                                     +
                                              " and i.submission_id = su.submission_id ")
   @show_nav_bar = true
   render(:layout => 'submission')
  end

  def clone_instrument
    i = Instrument.find(params[:id])             #  get source record
    n = Instrument.new(i.attributes)             #  build new Instrument object based on existing
    n.submission_id = session[:submiss_id]
    n.save                                       #  write new "cloned" record to database

    @show_nav_bar = true
    redirect_to :action => 'list'
  end

  private

  def is_member_of
    if Instrument.find_by_id_and_submission_id(params[:id], session[:submiss_id])
      return true
    else
      redirect_to(:controller => 'submission', :action => 'show_my')
      return false
    end
  end


end
