class SpectrumController < ApplicationController
  include ApplicationHelper

  before_filter :is_member_of, :only => [:show, :edit, :destroy]

  def index
    session[:submiss_id] = '24'
    list
    # render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify :method => :post, :only => [ :destroy, :create, :update ],
  #        :redirect_to => { :action => :list }

  def list
    @spectrums = Spectrum.find(:all,
                               :select      => 'spct.id, spct.specimen_id, spct.seqnum, spct.data_filename, spct.specimen_calibration, spec.seqnum as spec_seq',
                               :conditions  => ["spct.submission_id = ? ", session[:submiss_id] ],
                               :joins       => "as spct left outer join specimens as spec on spct.specimen_id = spec.id",
                               :order       => "spct.seqnum" )
    @show_nav_bar = true
    render(:layout => 'submission')

  end

  def show
    @spectrum = Spectrum.find(params[:id])
    @show_nav_bar = true
    render(:layout => 'submission')
  end

  def new
    @edit_new = 'New'
    @spectrum = Spectrum.new
    session[:spectrum_id] = nil
    session[:new_rec_id]  = nil
    @show_nav_bar = true
    load_listboxes()
    @field_list = get_html_form_fields('spectra', @spectrum, session[:show_help])
    render(:layout => 'submission', :action => 'edit')
  end

  def create
    @spectrum = Spectrum.new(params[:field_name] => params[:field_value])
    @spectrum.submission_id = session[:submiss_id]
    @spectrum.save
    session[:spectrum_id] = @spectrum.id
    session[:new_rec_id]  = @spectrum.id
  end


  def edit
    @edit_new = 'Editing'
    if params[:id]                            # editing an existing record
      @spectrum = Spectrum.find(params[:id])
    elsif session[:spectrum_id]               # editing a newly-entered record
      @spectrum = Spectrum.find(session[:spectrum_id])
    else
      new()                                   # user is jumping back from a look-up tab on the Spectra edit page
                                              #  & there is no new Spectra record yet
      return
    end
    session[:spectrum_id] = @spectrum.id
    load_listboxes()
    @show_nav_bar = true
    @spectrum.paramset_id = calc_paramset_id_display_val()
    @field_list = get_html_form_fields('spectra', @spectrum, session[:show_help])
    render(:layout => 'submission')
  end

  def update(my_spectrum)
    @spectrum = Spectrum.find(my_spectrum)
    @spectrum.update_attribute(params[:field_name], params[:field_value])
  end

  def destroy
    Spectrum.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def show_upload_tab
    @data_file = Spectrum.new
    @show_nav_bar = true
    render(:layout => 'submission', :action => 'file_upload')
  end

  def show_paramset_tab
    # get a list of paramsets
    @paramsets = Paramset.find(:all,
                               :select      => 'pset.id, seqnum, excitation_source_label, excite_src_char_energy, pass_energy_retard_rat, analyzer_resolution, technique',
                               :conditions  => ["inst.submission_id = ? ", session[:submiss_id] ],
                               :joins       => "as pset left outer join instruments as inst on pset.instrument_id = inst.id",
                               :order       => "pset.seqnum" )
    @show_nav_bar = true
    render(:layout => 'submission', :action => 'paramset_list')
  end

  def save_data_file
#    if params[:spectrum['uploaded_file']] != ''
    @spectrum = Spectrum.find(session[:spectrum_id])
    @spectrum.update_attributes(params[:spectrum])
    @show_nav_bar = true

    load_listboxes()
    @spectrum.paramset_id = calc_paramset_id_display_val()  # 'hijacking' this field for display in read-only field, never saved
    @field_list = get_html_form_fields('spectra', @spectrum, session[:show_help])
    render(:layout => 'submission', :action => 'edit')
#    end

  end

  def select_paramset
    @spectrum = Spectrum.find(session[:spectrum_id])
    @spectrum.paramset_id = params[:id]
    @spectrum.save
    @show_nav_bar = true

    load_listboxes()
    @spectrum.paramset_id = calc_paramset_id_display_val()  # 'hijacking' this field for display in read-only field, never saved
    @field_list = get_html_form_fields('spectra', @spectrum, session[:show_help])

    render(:layout => 'submission', :action => 'edit')
  end

  def on_field_change
    super
  end


  def load_listboxes()
    @suggested_pub_status_choices = Lookup.get_listbox_choices('spectra', 'suggested_pub_status')
    @specimen_calibration_choices = Lookup.get_listbox_choices('spectra', 'specimen_calibration')
    @abscissa_label_choices       = Lookup.get_listbox_choices('spectra', 'abscissa_label')
    @signal_mode_choices          = Lookup.get_listbox_choices('spectra', 'signal_mode')
    @signal_intensity_correction_choices = Lookup.get_listbox_choices('spectra', 'signal_intensity_correction')
    @spectrum_modul_method_choices       =  Lookup.get_listbox_choices('spectra', 'spectrum_modul_method')

    @specimen_id_choices = Specimen.find_all_by_submission_id(session[:submiss_id]).map { |sp| [sp.host, sp.id] }
    @specimen_id_choices.insert(0, ['-', 0])

  end

  def calc_paramset_id_display_val()
   display_val = ''
   if @spectrum.paramset_id
     pi = Paramset.find(:first, :conditions => "id = #{@spectrum.paramset_id}")
     if pi
       display_val = pi.seqnum.to_s
     end
   end

   return display_val

  end

  private

  def is_member_of
    if Spectrum.find_by_id_and_submission_id(params[:id], session[:submiss_id])
      return true
    else
      redirect_to(:controller => 'submission', :action => 'show_my')
      return false
    end
  end

end
