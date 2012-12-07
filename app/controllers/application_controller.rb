class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper


# moved to its own file in Models ???JL 17Jul2012
# class HtmlFormRec
# 	  attr_reader :field_name, :field_label, :display_widget, :display_widget_width, :display_widget_height, :help_text, :model_name, :record_id, :contrib_form_id, :field_data
# 	    def initialize(field_name, field_label, display_widget, display_widget_width, display_widget_height, help_text, model_name, record_id, contrib_form_id, field_data )
# 	      @field_name             = field_name
# 	      @field_label            = field_label
# 	      @display_widget         = display_widget
# 	      @display_widget_width   = display_widget_width
# 	      @display_widget_height  = display_widget_height
# 	      @help_text              = help_text
# 	      @model_name             = model_name
# 	      @record_id              = record_id
# 	      @contrib_form_id        = contrib_form_id
# 	      @field_data             = field_data
# 	    end
# 	end
  

# moved to application_helper Module ???JL 17Jul2012
  # def get_html_form_fields(form_id_in, data_object_in)  # consider putting this method into the HtmlFormRec class 1/14/2008 16:25 ???JL
  #   field_list = Array.new

  #   @field_master = FieldMaster.get_form_fields(form_id_in)

  #   # Match list of fields to be displayed (from FieldMaster) w/ fields from the Model object
  #   #  and display only the ones that match.
  #   @field_master.each { |fm_rec|
  #     if data_object_in.attributes.has_key?(fm_rec.wecf_field_name) or (fm_rec.html_widget.include?('subhdg'))
  #       if session[:show_help] == ''    # can this be replaced by blank? method
  #         fm_rec.help_text = nil
  #       end
  #       myrec = HtmlFormRec.new(fm_rec.wecf_field_name, fm_rec.contrib_form_prompt, fm_rec.html_widget,
  #                               fm_rec.html_widget_width, fm_rec.html_widget_height, fm_rec.help_text,
  #                               data_object_in.class.to_s, data_object_in.id, fm_rec.contrib_form_id,
  #                               data_object_in[fm_rec.wecf_field_name] )
  #       field_list.push(myrec)
  #     end
  #   }
  #   return field_list
  # end  # get_html_form_fields()


  def check_new
    if session[:submiss_id] == '* New *'
      flash[:notice] = 'Please enter a Title for this new Submission... <br><br>(or click My Submissions in Title Bar to select an existing Submission)'
      redirect_to(:controller => 'submission', :action => 'new')
      return true
    end
  end


  def update_instr_info_in_tv()
    a = Array.new
    instr_recs = Instrument.find_all_by_submission_id(session[:submiss_id])
    instr_recs.each {|x| a.push(x.model, x.id)}
    session[:arr_instr_info] = a       # array looks like: ['Perkin-Elmer XPS 5000', 4459]   ???JL
    session[:instrument_id]  = a[1]    # Kludge! - This won't work if a submiss has multiple instruments (not all that likely)
  end                                  #  this was done so that the Submiss Proof report would run correctly - 6/30/2008 09:30 JL


  def on_field_change
    if params[:id]                  # if we are updating an existing record params[:id] will not be nil
      # logger.warn('1 fired')
      update(params[:id])           # Update existing record
    elsif session[:new_rec_id]      # params[:id] will be nil when creating a new object (as opposed to editing existing)
      # logger.warn('2 fired')
      update(session[:new_rec_id])  # Update "New" record
    else                            # we must create a new record
      # logger.warn('3 fired')
      create()
    end
    render(:nothing => true)
  end  # on_field_change
	

end
