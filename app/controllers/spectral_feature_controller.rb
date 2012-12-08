class SpectralFeatureController < ApplicationController

include ApplicationHelper

  before_filter :is_member_of, :only => [:show_spect_feat, :show_calib_info, :edit_spect_feat, :edit_calib_info, :destroy_spect_feat, :destroy_calib_info]

  layout "submission"

  def list_spect_feat
		@spectral_feat_tbl_unit = SpectralFeatTblUnit.find_by_submission_id(session[:submiss_id])
		if !@spectral_feat_tbl_unit
			@spectral_feat_tbl_unit = SpectralFeatTblUnit.new
		end
    @list_pg_title = 'Section I - Spectral Features Listing'
    @spect_feats   = get_spect_feats('specimen')
    @edit_action   = 'spect_feat'
    session[:spect_feat_edit_action] = 'spect_feat'
    @show_nav_bar  = true
    render(:layout => 'submission', :template => 'spectral_feature/list')
  end

  def list_calib_info
    @list_pg_title = 'Section D - Calibration Info Listing'
    @spect_feats   = get_spect_feats('calibration')
    @edit_action   = 'calib_info'
    @show_nav_bar  = true
    session[:spect_feat_edit_action] = 'calib_info'
    render(:layout => 'submission', :template => 'spectral_feature/list')
  end

  def new_spect_feat
    session[:new_rec_id] = nil
    session[:spectral_type_flag]  = 'specimen'
    @spectral_feature    = SpectralFeature.new
    @spectrum_id_choices =  get_spectra_list('specimen')
    @edit_pg_title       = 'Section I - New Spectral Feature Record'
    @edit_action         = 'create_spect_feat'
    @edit_new_flag       = 'New'
    @back_url            = 'list_spect_feat'
    @show_nav_bar        = true
    @field_list = get_html_form_fields('spectral_features', @spectral_feature, session[:show_help])
    render(:layout => 'submission', :template => 'spectral_feature/edit')
  end

  def new_calib_info
    session[:new_rec_id] = nil
    session[:spectral_type_flag]  = 'calibration'
    @spectral_feature    = SpectralFeature.new
    @spectrum_id_choices =  get_spectra_list('calibration')
    @edit_pg_title       = 'Section D - New Calibration Info Record'
    @edit_action         = 'create_calib_info'
    @edit_new_flag       = 'New'
    @show_nav_bar        = true
    @field_list = get_html_form_fields('spectral_features', @spectral_feature, session[:show_help])
    render(:layout => 'submission', :template => 'spectral_feature/edit')
  end

  def create
    @spectral_feature = SpectralFeature.new(params[:field_name] => params[:field_value]) # (params[:spectral_feature])
    #@spectral_feature = SpectralFeature.new(params[:spectral_feature])
    @spectral_feature.submission_id = session[:submiss_id]
    @spectral_feature.spectral_type = session[:spectral_type_flag]
    @spectral_feature.save
    session[:new_rec_id] = @spectral_feature.id
  end  

  # def create_calib_info
  #   # @spectral_feature = SpectralFeature.new(params[:field_name] => params[:field_value]) # (params[:spectral_feature])
  #   @spectral_feature = SpectralFeature.new(params[:spectral_feature])
  #   @spectral_feature.submission_id = session[:submiss_id]
  #   @spectral_feature.spectral_type = session[:spectral_type_flag]
  #   @spectral_feature.save
  #   session[:new_rec_id] = @spectral_feature.id
  #   redirect_to( :action => 'list_calib_info' )
  # end  


  # def create()
  #   if session[:spectral_type_flag] == 'calibration'
  #     make_new('calibration')
  #   else
  #     make_new('specimen')
  #   end
  # end

  # def make_new(type)
  #   @spectral_feature = SpectralFeature.new(params[:field_name] => params[:field_value]) # (params[:spectral_feature])
  #   @spectral_feature.submission_id = session[:submiss_id]
  #   @spectral_feature.spectral_type = type
  #   @spectral_feature.save
  #   session[:new_rec_id] = @spectral_feature.id
  # end  # make_new()

  def edit_spect_feat
    @spectral_feature    = SpectralFeature.find(params[:id])
    @spectrum_id_choices =  get_spectra_list('specimen')
    @edit_pg_title       = 'Section I - Editing Spectral Feature'
    @edit_action         = 'update_spect_feat'
    @edit_new_flag       = 'Editing'
    @back_url            = 'list_spect_feat'
    @show_nav_bar        = true
    @field_list = get_html_form_fields('spectral_features', @spectral_feature, session[:show_help])
    render(:layout => 'submission', :template => 'spectral_feature/edit')
  end

  # def update_spect_feat           
  #   @spectral_feature = SpectralFeature.find(params[:id])
  #   @spectral_feature.update_attributes(params[:spectral_feature])
  #   redirect_to( :action => 'list_spect_feat' )
  # end

  def edit_calib_info
    @spectral_feature    = SpectralFeature.find(params[:id])
    @spectrum_id_choices = get_spectra_list('calibration')
    @edit_pg_title       = 'Section D - Editing Calibration Info'
    @edit_new_flag       = 'Editing'
    @edit_action         = 'update_calib_info'
    @back_url            = 'list_calib_info'
    @show_nav_bar        = true
    @field_list          = get_html_form_fields('spectral_features', @spectral_feature, session[:show_help])
    render(:layout => 'submission', :template => 'spectral_feature/edit')
  end

  # def update_calib_info
  #   @spectral_feature = SpectralFeature.find(params[:id])
  #   @spectral_feature.update_attributes(params[:spectral_feature])
  #   redirect_to( :action => 'list_calib_info' )
  # end

  def update(my_spect_feat_id)
    @spectral_feature = SpectralFeature.find(my_spect_feat_id)
    @spectral_feature.update_attributes(params[:field_name] => params[:field_value] )   #(params[:spectral_feature])
  end

  def show_calib_info
    @spectral_feature = SpectralFeature.find(params[:id])
    @show_pg_title    = 'Section D - Showing Calibration Info record'
    @edit_action      = 'calib_info'
    @show_nav_bar     = true
    render(:layout => 'submission', :template => 'spectral_feature/show')
  end

  def show_spect_feat
    @spectral_feature = SpectralFeature.find(params[:id])
    @show_pg_title    = 'Section I - Showing Spectral Feature record'
    @edit_action      = 'spect_feat'
    @show_nav_bar     = true
    render(:layout => 'submission', :template => 'spectral_feature/show')
  end

  def destroy_spect_feat
    SpectralFeature.find(params[:id]).destroy
    redirect_to :action => 'list_spect_feat'
  end

  def destroy_calib_info
    SpectralFeature.find(params[:id]).destroy
    redirect_to :action => 'list_calib_info'
  end

  def get_spect_feats(type)
    spect_feats = SpectralFeature.find(:all,
                                       :select      => 'sf.id, sf.spectrum_id, sf.seqnum, sf.element, sf.peak_transition, ' +
                                                       'sf.peak_energy, sf.peak_fwhm, sf.peak_sensitivity, sf.concentration, ' +
                                                       'sf.peak_assignment, spect.seqnum as spect_seq',
                                       :conditions  => ["sf.submission_id = ? and sf.spectral_type = ? ", session[:submiss_id], type],
                                       :joins       => "as sf left outer join spectra as spect on sf.spectrum_id = spect.id",
                                       :order       => "sf.seqnum, spect.seqnum" )
  end  # get_spect_feats

  def get_spectra_list(type)
    # Populate the Spectra-selection combo box:
    # Get all spectra (and child Named Peaks) for current Submiss where specimen_calibration = 'specimen' or 'calibration'
    @spectrum_list = Spectrum.find(:all,
                                   :select     => 'id, seqnum, data_filename',
                                   :conditions => ["submission_id = ? and specimen_calibration = ? ", session[:submiss_id], type ],
                                   :order      => 'seqnum')        #.map { |s| [s.seqnum.to_s + ' - ' + s.data_filename, s.id] }
    cb_list = Array.new
      cb_list.push(['-', nil])
      for spectrum in @spectrum_list
        named_peaks = NamedPeak.find_all_by_spectrum_id(spectrum.id).map {|np| ["#{np.species_label} #{np.transition_label}"]}
        np_string = named_peaks.join(', ')
        if np_string.length > 20 then
          np_string = np_string.slice(0, 20) + '...'
        end
        cb_list.push(["#{spectrum.seqnum} - #{np_string} - #{spectrum.data_filename}", spectrum.id])
      end

    return cb_list
  end  # get_spectra_list()

  def on_field_change
    super
  end


  private

  def is_member_of
    if SpectralFeature.find_by_id_and_submission_id(params[:id], session[:submiss_id])
      return true
    else
      redirect_to(:controller => 'submission', :action => 'show_my')
      return false
    end
  end

end  # class SpectralFeatureController
