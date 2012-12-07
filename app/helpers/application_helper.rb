module ApplicationHelper

	def title()
		base_title = 'Ruby on Rails Tutorial Sample App'
		if @title.nil?
			base_title
		else
			"#{base_title} | #{@title} "
		end
	end

	
  def foo
  	puts('im foo')
  end


  def get_html_form_fields(form_id_in, data_object_in, show_help_flag_in)  # consider putting this method into the HtmlFormRec class or FieldMaster Model 7/17/2012 16:25 ???JL
	  field_list = Array.new

	  @field_master = FieldMaster.get_form_fields(form_id_in)

	  # Match list of fields to be displayed (from FieldMaster) w/ fields from the Model object
	  #  and display only the ones that match.
	  @field_master.each { |fm_rec|
	    if data_object_in.attributes.has_key?(fm_rec.wecf_field_name) or (fm_rec.html_widget.include?('subhdg'))
	      if show_help_flag_in == ''
	        fm_rec.help_text = nil
	      end
	      myrec = HtmlFormRec.new(fm_rec.wecf_field_name, fm_rec.contrib_form_prompt, fm_rec.html_widget,
	                              fm_rec.html_widget_width, fm_rec.html_widget_height, fm_rec.help_text,
	                              data_object_in.class.to_s, data_object_in.id, fm_rec.contrib_form_id,
	                              data_object_in[fm_rec.wecf_field_name] )
	      field_list.push(myrec)
	    end
	  }
	  return field_list
  end  # get_html_form_fields()
  

  def build_cs_str(list, field_name)    # build comma-separated string
    arr = Array.new
    list.each{ |x| arr.push(x[field_name]) }
    return arr.join(', ')
  end


end
