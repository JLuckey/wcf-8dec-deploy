class SpecimenController < ApplicationController

include ApplicationHelper

#  before_filter :is_member_of, :only => [:show, :edit, :destroy, :update]

  def index
    list
    #render :action => 'list'

  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  # verify :method => :post, :only => [ :destroy, :create, :update ],
  #        :redirect_to => { :action => :list }

  def list
    @specimens = Specimen.find_all_by_submission_id(session[:submiss_id], :order => 'seqnum')
    @show_nav_bar = true
    render(:layout => 'submission')
  end

  def show
    @specimen = Specimen.find(params[:id])
    @show_nav_bar = true
    render(:layout => 'submission')
  end

  def new
    session[:new_rec_id] = nil
    load_listboxes()
    @specimen = Specimen.new
    @edit_new_flag = 'New'
    @show_nav_bar = true
    @field_list = get_html_form_fields('specimens', @specimen, session[:show_help])
    render(:layout => 'submission', :template => 'specimen/edit')
  end

  def create
    @specimen = Specimen.new(params[:specimen])
    @specimen.submission_id = session[:submiss_id]
    @specimen.save
    session[:new_rec_id] = @specimen.id
  end

  def update(my_specimen_id)
    @specimen = Specimen.find(my_specimen_id)
    @specimen.update_attributes(params[:field_name] => params[:field_value] )
  end

  # def update                    # (my_specimen_id)
  #   @specimen = Specimen.find(params[:id])
  #   @specimen.update_attributes(params[:specimen])
  #   redirect_to({:action=> 'show', :id => @specimen})

  #   # @specimen.update_attributes(params[:field_name] => params[:field_value] )
  # end


  def load_listboxes     # the following instance vars must have the exact field name (as it appears in its table) + '_choices'
    @homogeneity_choices                = Lookup.get_listbox_choices('specimens', 'homogeneity')
    @crystallinity_choices              = Lookup.get_listbox_choices('specimens', 'crystallinity')
    @phase_choices                      = Lookup.get_listbox_choices('specimens', 'phase')
    @material_family_choices            = Lookup.get_listbox_choices('specimens', 'material_family')
    @electrical_characteristic_choices  = Lookup.get_listbox_choices('specimens', 'electrical_characteristic')
    @special_material_classes_choices   = Lookup.get_listbox_choices('specimens', 'spec_matl_classes')

  end

  def destroy
    Specimen.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def on_field_change
    super
  end


	def edit  #test_field_group
    @show_nav_bar = true
    @edit_new_flag = 'Editing'
    load_listboxes()
    @specimen   = Specimen.find(params[:id])
    @field_list = get_html_form_fields('specimens', @specimen, session[:show_help])
    render(:layout => 'submission', :template => 'specimen/edit')
  end


  def edit_of_test      # of = Observe Field
    @specimen = Specimen.find(params[:id])

  end    

  private

  # def is_member_of    # is user a member of submission x
  #   if Specimens.find_by_id_and_submission_id(params[:id], session[:submiss_id])
  #     return true
  #   else
  #     redirect_to(:controller => 'submission', :action => 'show_my')
  #     return false
  #   end
  # end

end
