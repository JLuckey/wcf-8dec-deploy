class SimsIonSourcesController < ApplicationController
  # GET /sims_ion_sources
  # GET /sims_ion_sources.json
  def index
    @sims_ion_sources = SimsIonSource.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sims_ion_sources }
    end
  end

  # GET /sims_ion_sources/1
  # GET /sims_ion_sources/1.json
  def list
    @title = 'testTitle'
    @ion_sources = SimsIonSource.all

    # @sims_ion_source = SimsIonSource.find(params[:id])

    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.json { render json: @sims_ion_source }
    # end
    @show_nav_bar = true
    render(:layout => 'submission')
  end

  # GET /sims_ion_sources/new
  # GET /sims_ion_sources/new.json
  def new
    @sims_ion_source = SimsIonSource.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sims_ion_source }
    end
  end

  def new_submenu
    @title = 'testTitle'
    @show_nav_bar = true
    render(:layout => 'submission')
  end

  def new_magsect_quad
    @title = 'new_magsect_quad'
    @show_nav_bar = true
    render(:layout => 'submission')
  end


  def new_tof
    @title = 'New SIMS Time of Flight'
    @show_nav_bar = true
    render(:layout => 'submission')
  end


  # GET /sims_ion_sources/1/edit
  def edit
    @sims_ion_source = SimsIonSource.find(params[:id])
  end

  # POST /sims_ion_sources
  # POST /sims_ion_sources.json
  def create
    @sims_ion_source = SimsIonSource.new(params[:sims_ion_source])

    respond_to do |format|
      if @sims_ion_source.save
        format.html { redirect_to @sims_ion_source, notice: 'Sims ion source was successfully created.' }
        format.json { render json: @sims_ion_source, status: :created, location: @sims_ion_source }
      else
        format.html { render action: "new" }
        format.json { render json: @sims_ion_source.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sims_ion_sources/1
  # PUT /sims_ion_sources/1.json
  def update
    @sims_ion_source = SimsIonSource.find(params[:id])

    respond_to do |format|
      if @sims_ion_source.update_attributes(params[:sims_ion_source])
        format.html { redirect_to @sims_ion_source, notice: 'Sims ion source was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @sims_ion_source.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sims_ion_sources/1
  # DELETE /sims_ion_sources/1.json
  def destroy
    @sims_ion_source = SimsIonSource.find(params[:id])
    @sims_ion_source.destroy

    respond_to do |format|
      format.html { redirect_to sims_ion_sources_url }
      format.json { head :ok }
    end
  end
end
