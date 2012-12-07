class SimsInstrumentConfigurationsController < ApplicationController
  # GET /sims_instrument_configurations
  # GET /sims_instrument_configurations.json
  def index
    @sims_instrument_configurations = SimsInstrumentConfiguration.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sims_instrument_configurations }
    end
  end


  def list
    @instruments  = SimsInstrumentConfiguration.find_all_by_submission_id(session[:submiss_id])  # this will change when we begin using the sims_instruments table
    update_instr_info_in_tv()
    @show_nav_bar = true
    render(:layout => 'submission')
  end



  # GET /sims_instrument_configurations/1
  # GET /sims_instrument_configurations/1.json
  def show
    @sims_instrument_configuration = SimsInstrumentConfiguration.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sims_instrument_configuration }
    end
  end


  def new_submenu
    # update_instr_info_in_tv()
    @show_nav_bar = true
    render(:layout => 'submission')
  end


  # GET /sims_instrument_configurations/new
  # GET /sims_instrument_configurations/new.json
  def new
    @sims_instrument_configuration = SimsInstrumentConfiguration.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sims_instrument_configuration }
    end
  end

  def new_mag_sector
    # session[:new_rec_id] = nil
    # load_listboxes()
    # @instrument = Instrument.new
    # @edit_new_flag = 'New'
    @show_nav_bar = true
    # @field_list = get_html_form_fields('instruments', @instrument, session[:show_help])
    render(:layout => 'submission')   #, :template => 'instrument/edit')
  end


  def new_quad
    # session[:new_rec_id] = nil
    # load_listboxes()
    # @instrument = Instrument.new
    # @edit_new_flag = 'New'
    @show_nav_bar = true
    # @field_list = get_html_form_fields('instruments', @instrument, session[:show_help])
    render(:layout => 'submission')   #, :template => 'instrument/edit')
  end


  def new_tof
    # session[:new_rec_id] = nil
    # load_listboxes()
    # @instrument = Instrument.new
    # @edit_new_flag = 'New'
    @show_nav_bar = true
    # @field_list = get_html_form_fields('instruments', @instrument, session[:show_help])
    render(:layout => 'submission')   #, :template => 'instrument/edit')
  end


  # GET /sims_instrument_configurations/1/edit
  def edit
    @sims_instrument_configuration = SimsInstrumentConfiguration.find(params[:id])
  end

  # POST /sims_instrument_configurations
  # POST /sims_instrument_configurations.json
  def create
    @sims_instrument_configuration = SimsInstrumentConfiguration.new(params[:sims_instrument_configuration])

    respond_to do |format|
      if @sims_instrument_configuration.save
        format.html { redirect_to @sims_instrument_configuration, notice: 'Sims instrument configuration was successfully created.' }
        format.json { render json: @sims_instrument_configuration, status: :created, location: @sims_instrument_configuration }
      else
        format.html { render action: "new" }
        format.json { render json: @sims_instrument_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sims_instrument_configurations/1
  # PUT /sims_instrument_configurations/1.json
  def update
    @sims_instrument_configuration = SimsInstrumentConfiguration.find(params[:id])

    respond_to do |format|
      if @sims_instrument_configuration.update_attributes(params[:sims_instrument_configuration])
        format.html { redirect_to @sims_instrument_configuration, notice: 'Sims instrument configuration was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @sims_instrument_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sims_instrument_configurations/1
  # DELETE /sims_instrument_configurations/1.json
  def destroy
    @sims_instrument_configuration = SimsInstrumentConfiguration.find(params[:id])
    @sims_instrument_configuration.destroy

    respond_to do |format|
      format.html { redirect_to sims_instrument_configurations_url }
      format.json { head :ok }
    end
  end
end
