class SubmissionProofPdf < Prawn::Document

# To-dos:
  #   1. set default font for majority of doc in initialize()
  #   2. code for individual cell alignments, row-coloring, adjust table size to page width in Section D - compare to old code
  #   3. should spacing between sections be controlled in main calling proc ???JL
  #   4. analyze this code for data-missing/data-related bugs
  #   5. alternate row row-coloring
  #   6. eliminate row lines ??
  #   7. create column headings like "Spectrum 1" "Spectrum 2"
  #   8. Get rid of extra page after last Section F table - seems to be adding an extra/un-needed page - move this up
  #   9. Analyze strange characters in names - different char set in european names
  #   10. update Prawn wiki w/ outcome for wierd PDF error:  wrong number of arguments for a setcolor operator
	# D 11. find the Ruby way to do dorf()

  include ApplicationHelper

 	def initialize(submissIn, sessionIn)
    super( top_margin: 54, left_margin: 54, right_margin: 36, bottom_margin: 36, :page_size => "LETTER", :page_layout => :portrait )
    @submiss = submissIn
    @session = sessionIn
    report_header() 
    bounding_box [0, 670], :width => 522, :height => 620 do   # bounding box includes all text & excludes page headers & footers
      move_down 14
      text("<b>#{@submiss.title}</b>", :size => 14, :inline_format => true)  # Submission Title
      move_down 9
	    authors_section()
      sectionA()
      sectionB()				 # Specimens
	    sectionC()				 # Instruments
      sectionD()         # Calibration Info
      sectionE()         # Variable Instrument Params
      sectionF()         # Spectra
      sectionH()         # Analysis Methods
      sectionI()         # Spectral Features
    end

    page_header_footer()
    # number_pages must appear at end of document to include all pages, per Prawn documentation
    number_pages "<page> of <total>",  # page number position/spacing must align w/ Page Footer text - see page_header_footer()
                 {:start_count_at => 1,
                  :at => [bounds.left, bounds.bottom + 14],
                  :align => :center,
                  :size => 7}
 	end


  def report_header
		# Document Title
		font("Helvetica", :style => :bold)
    text('Surface Science Spectra', :size => 18)
    text("WCF Submission #{@submiss.id} Proof #{@submiss.sss_ms_num.blank? ? '' : ' - SSS Submission # ' + @submiss.sss_ms_num} ", :font_size => 16)
    stroke_horizontal_rule()
  end

  def page_header_footer
    # header - on every page except the first page
  	repeat 2..page_count do	
      bounding_box [bounds.left, bounds.top], :width  => bounds.width do
        font "Helvetica"
  		  title = @submiss.title.size > 60 ? (@submiss.title[0..60] + '...') : @submiss.title
			  text "#{title}  (WCF ID #{@submiss.id})", :align => :left, :size => 8
			  draw_text( Time.now.to_s(:db), :at => [bounds.width - 74, cursor + 3], :size => 8 )
        stroke_horizontal_rule
      end
    end  

	  # footer - on every page, including first page - footer looks like:
	  # Surface Science Spectra - Submission # 20080101(35209)        2 of 12                      www.PublishInSSS.com
  	repeat( 1..page_count ) do  # , :dynamic => true   # :dynamic option causes bug pdf doc error (not rails error) "wrong number of arguments for a setcolor operator"
	    bounding_box [bounds.left, bounds.bottom + 18], :width  => bounds.width do
        font "Helvetica"
        stroke_horizontal_rule
        move_down(12)
			  t = "Surface Science Spectra #{@submiss.sss_ms_num.blank? ? '' : '- Submission # ' + @submiss.sss_ms_num} "
        draw_text( t, :at => [bounds.left, cursor + 3], :size => 7 )
        draw_text( 'www.PublishInSSS.com', :at => [bounds.width - 74, cursor + 3], :size => 7 )
	    end
  	end

  end  # page_header_footer


  def authors_section
  	font("Times-Roman")
		text('', :size => 10)
		author_group = calc_author_groups()
    if !author_group.blank?
	    author_group.each do |ag|
	      text(ag.name_string, :size => 10)
	      text('<i>' + ag.org_string + '</i>', :size => 10, :inline_format => true)
	      text(' ')
	  	end
	  else
			text('Authors Section does not contain any data')
    end
  	
  end  # authors_section


  def sectionA
  	submission = Submission.find(@session[:submiss_id])
  	submission_field_list = get_html_form_fields('submissions', submission, @session[:show_help])
		submission_field_list.delete_at(0)    # Removing the Submission Title from this listing because it is already shown above
		submission_field_list.each do |ifl|
			# adjust formatting for entries like sub-headings which don't have a leading Field Designator (e.g. A-3b.)
			form_id_val = ifl.contrib_form_id.blank?  ? '' : "#{ifl.contrib_form_id}  "
			text("<b>#{form_id_val}#{ifl.field_label} </b> #{ifl.field_data}", :size => 10, :inline_format => true)
    	text(' ')
		end
	
		# Keywords
		keywords_list = Keyword.find(:all, :conditions => ["submission_id = ?", @session[:submiss_id]], :order => "seqnum")
    kw_string = build_cs_str(keywords_list, 'keyword')
    text("<b>Keywords: </b> #{kw_string}", :size => 10, :inline_format => true)
    move_down(20)

		# Major Elements
    major_elements_list = MajorElement.find(:all, :conditions => ["submission_id = ?", @session[:submiss_id]], :order => "seqnum")
    maj_element_string = build_cs_str(major_elements_list, 'major_element_name')
    text("<b>Major Elements in Spectrum: </b> #{maj_element_string}", :size => 10, :inline_format => true )
    move_down(20)

		# Minor Elements
    minor_elements_list = MinorElement.find(:all, :conditions => ["submission_id = ?", @session[:submiss_id]], :order => "seqnum")
    min_element_string = build_cs_str(minor_elements_list, 'minor_element_name')
    text("<b>Minor Elements in Spectrum: </b> #{min_element_string}", :size => 10, :inline_format => true )
    move_down(20)

    # References
    text('<b>SECTION A - REFERENCES</b>', :size => 10, :inline_format => true)
    horizontal_rule
    stroke
    move_down(20)

		reference_list = SubmissionReference.find(:all, :conditions => ["submission_id = ?", @session[:submiss_id]], :order => 'seqnum')
		if reference_list.size > 0
			reference_list.each do |reference|
				reference_authors_list = ReferenceAuthor.find(:all, :conditions => ["submission_reference_id = ?", reference.id], :order => 'seqnum')
				author_arr = Array.new
				reference_authors_list.each do |author|
					author_arr.push("#{author.fname} #{author.lname}")
			  end  # reference_authors_list
			  text("<b>Reference #:</b> #{reference.seqnum}", :size => 10, :inline_format => true )
			  text("  <b>Authors:</b> #{author_arr.join(', ')}", :size => 10, :inline_format => true )

  			if !reference.pub_type.blank?
          case reference.pub_type.downcase
    				when 'journal'
              text("  #{reference['title']} #{reference['volume']}, #{reference['pages']} (#{reference['year_published']})", :size => 10, :inline_format => true)

            when 'book'
              text("  #{reference['title']} #{reference['edition']} #{format_publisher_info(reference)} #{reference['chapter']} #{reference['pages']}", :size => 10, :inline_format => true )
                   
    				else  # 'other' pub_type
    	  			text("  #{reference['title']} #{format_publisher_info(reference)} #{reference['chapter']} #{reference['pages']}", :size => 10, :inline_format => true)
    			end
        else
          text("  #{reference['title']} #{format_publisher_info(reference)} #{reference['chapter']} #{reference['pages']}", :size => 10, :inline_format => true)
        end 
    		text(' ')
  	  end  
		else
			text('Reference Section does not contain any data')
		end
		text(' ')
  end # sectionA


  def sectionB		# Specimen Section - note: there can be multiple Specimens
		text('<b>SECTION B - SPECIMEN DESCRIPTION</b>', :size => 10, :inline_format => true)
    stroke_horizontal_rule
    text(' ')

		specimens_list = Specimen.find(:all, :conditions => ["submission_id = ?", @session[:submiss_id]], :order => "seqnum")
		if specimens_list.size > 0
			specimens_list.each do |specimen|
				specimen_field_list = get_html_form_fields('specimens', specimen, @session[:show_help])
				specimen_field_list.each do |ifl|
					form_id_val = ifl.contrib_form_id.blank?  ? '' : ifl.contrib_form_id + '  '
					text("<b>#{form_id_val}#{ifl.field_label} </b> #{ifl.field_data}", :size => 10, :inline_format => true)
    			text(' ')
				end
			end
		else
			text('Specimen Section does not contain any data')
		end
		text(' ')
  end  # sectionB


  def sectionC		# Instrument Section
		text('<b>SECTION C - INSTRUMENT DESCRIPTION</b>', :size => 10, :inline_format => true)
    horizontal_rule
    stroke
    text(' ')
    instruments_list = Instrument.find(:all, :conditions => ["submission_id = ?", @session[:submiss_id]])
		if instruments_list.size > 0
			instrument_field_list = get_html_form_fields('instruments', instruments_list[0], @session[:show_help])
			instrument_field_list.each do |ifl|
				form_id_val = ifl.contrib_form_id.blank?  ? '' : "#{ifl.contrib_form_id}   "
				text("<b>#{form_id_val}#{ifl.field_label} </b> #{ifl.field_data}", :size => 10, :inline_format => true)
    		text(' ')
			end
		else
			text('Instrument Section does not contain any data')
		end
    text(' ')
  end  # sectionC


  def sectionD
  	start_new_page()
    move_down 24
		text('<b>SECTION D - CALIBRATION INFORMATION</b>', :size => 12, :inline_format => true)
		stroke_horizontal_rule
    move_down 9
		build_spectral_features_table('calibration', 'Section D - Calibration Spectral Features')

    # table([ %w[Jeff Jennifer Mitchell],  # table command causes pdf doc error (not rails error) "wrong number of arguments for a setcolor operator"
    # 	      %w[Bob Ted Alice] ])
  end  # sectionD


  def sectionE
    move_down 36    # should spacing between sections be controlled in main calling proc ???JL
    text('<b>SECTION E - VARIABLE INSTRUMENT PARAMETERS </b>', :size => 12, :inline_format => true)
    stroke_horizontal_rule
    text(' ')

    # 4/27/2008 20:41 query instruments by submission_id  submissions ->> spectra -> paramset
    paramsets_list = Paramset.find(:all, :conditions => ["instrument_id = ?", @session[:instrument_id]])
    if paramsets_list.size > 0
      paramsets_list.each do |paramset|
        paramset_field_list = get_html_form_fields('paramsets', paramset, @session[:show_help])
        paramset_field_list.each do |pfl|
          form_id_val = pfl.contrib_form_id.blank?  ? '' : pfl.contrib_form_id + '  '
          text("<b>#{form_id_val}#{pfl.field_label} </b> #{pfl.field_data}", :size => 10, :inline_format => true)
          text(' ', :size => 10)
        end
      end  # do
    else
      text('Variable Instrument Parameters Section does not contain any data')
    end

  end   # sectionE


  def sectionF
    start_new_page
    text('<b>SECTION F - Spectra</b>', :inline_format => true)
    stroke_horizontal_rule
    move_down 18

    spectra_list = Spectrum.find(:all, :conditions => ["submission_id = ?", @session[:submiss_id]])
    if spectra_list.blank? 
      move_down 36
      text('Section F - Spectra does not contain any data')
      return
    end  
    table_arr  = Array.new    
    field_list = get_html_form_fields('submiss_summary_pdf', spectra_list[0], @session[:show_help])
    # 1. go thru each Spectrum record & write data from the desired fields (list of desired fields comes from
    #    get_html_form_fields() ) into elements of an array, one array for each Spectrum record.  Combine arrays 
    #    into 2 dim array.
    # 2. transpose (swap rows into columns) that 2 dim array 
    # 3. use transposed array to make table

    # calc the number of tables reqd to show all spectra with 4 data columns per table
    if spectra_list.size.modulo(4) > 0           
      table_count = spectra_list.size.div(4) + 1  
    else
      table_count = spectra_list.size.div(4)
    end
    spect_count = 0

    # Field labels (first column of table, after transpose)
    field_label_arr = Array.new
    field_label_arr << 'Field Name'
    field_list.each do |field|  
      field_label_arr << field.field_label
    end
    table_arr << field_label_arr

    # here's the heavy lifting
    1.upto(table_count) do |i|
      if (i > 1) and (i <= table_count)   # if not on first or last table 
        start_new_page
      end  
      4.times do                      # 4 data columns per table
        table_rec_arr = Array.new
        if spect_count < spectra_list.size
          table_rec_arr << "Spectrum #{spect_count + 1}" # CalcSpectrumColumnTitles(spect_count, spectra_list.size)
        else
          table_rec_arr << nil   # this code blanks-out the colum headings when there are empty columns in a table
        end  
        field_list.each do |field|  
          if spect_count >= spectra_list.size
            table_rec_arr << nil      # creating arrays w/ nill elements to fill-in tables where there were less than 4 data records in order to 
                                      #  maintain proper table dimensions for tables where there are fewer that 4 data sets.
          else  
            case field.field_name     # fields that require special processing
            when 'specimen_id'
              table_rec_arr << get_specimen_id_data(spectra_list[spect_count])

            when 'paramset_id'
              table_rec_arr << get_paramset_id_data(spectra_list[spect_count])

            when 'id'     # field name comes from "wecf_field_name" field in field_masters table
              table_rec_arr << get_named_peaks_data(spectra_list[spect_count])

            else
              table_rec_arr << spectra_list[spect_count].attributes[field.field_name]
            end
          end
        end
        table_arr << table_rec_arr
        spect_count += 1
      end

      # here's the magic 'transpose' method (swapping rows into columns)
      table(table_arr.transpose, {:header        => true, 
                                  :cell_style    => {:size => 9, :align => :left}, 
                                  :column_widths => [72, 112, 112, 112, 112] } )  do
        row(0).style :align => :center, :font_style => :bold   # center & bold the table header
      end

      table_arr.clear
      table_arr << field_label_arr
    end 

  end  # sectionF


  def get_specimen_id_data(spectra_rec_in)

    if spectra_rec_in.attributes['specimen_id'].blank?
      return 'specimem id is blank'
    else
      begin
        specimens_rec = Specimen.find(spectra_rec_in.attributes['specimen_id'])    # need to lookup Specimen's seqnum & host values
      rescue
        return "*** Error in get_specimen_id_data()! ***"
      else
        return "#{specimens_rec.seqnum} - #{specimens_rec.host}"
      end
    end
  end


  def get_paramset_id_data(spectra_rec_in)
    begin
      paramset_rec = Paramset.find( spectra_rec_in.attributes['paramset_id'] )    # need to lookup Paramset's Seqnum & Source Label values
    rescue
      return "*** Error in get_paramset_id_data()! ***"
    else
      return "#{paramset_rec.seqnum} - #{paramset_rec.excitation_source_label}"
    end
  
  end


  def get_named_peaks_data(spectra_rec_in)
    begin
      s = ''
      named_peaks_list = NamedPeak.find(:all, :conditions => ["spectrum_id = ?", spectra_rec_in.attributes['id']], :order => 'seqnum')
    rescue
      return "*** Error in get_named_peaks_data()! ***"
    else
      named_peaks_list.each do |np_rec|
        s << "#{np_rec.species_label} #{np_rec.transition_label}, "
      end
      return s.chomp(", ")
    end
  end
  

  def sectionH    # Section H - Analysis Methods
    move_down 36
    text('<b>SECTION H - ANALYSIS METHODS</b>', :font_size => 10, :inline_format => true)
    stroke_horizontal_rule
    move_down 12
    analysis_method = AnalysisMethod.find_by_submission_id(@session[:submiss_id])
    if analysis_method
      analysis_method_field_list = get_html_form_fields('analysis_methods', analysis_method, @session[:show_help])
      analysis_method_field_list.each do |amfl|
        form_id_val = amfl.contrib_form_id.blank?  ? '' : amfl.contrib_form_id + '  '
        text("<b>#{form_id_val}#{amfl.field_label} </b> #{amfl.field_data}", :size => 10, :inline_format => true)
        text(' ')
      end
    else
      text('Analysis Methods Section does not contain any data')
    end
    
  end  # sectionH


  def sectionI    # Spectral Features
    move_down 18
    text('<b>SECTION I - Units for Spectral Features Quantitative Fields</b>', :size => 10, :inline_format => true)
    stroke_horizontal_rule
    text(' ')

    spectral_feat_tbl_unit = SpectralFeatTblUnit.find_by_submission_id(@session[:submiss_id])
    if spectral_feat_tbl_unit
      spectral_feat_tbl_unit_field_list = get_html_form_fields('spectral_feat_tbl_units', spectral_feat_tbl_unit, @session[:show_help])
      spectral_feat_tbl_unit_field_list.each do |amfl|
        form_id_val = amfl.contrib_form_id.blank?  ? '' : amfl.contrib_form_id + '  '
        text("<b>#{form_id_val}#{amfl.field_label} </b> #{amfl.field_data}", :size => 10, :inline_format => true)
        text(' ')
      end
    else
      text('Quantitative Fields Section does not contain any data')
    end
    text(' ')
                                  
    build_spectral_features_table('specimen', 'Section I - Spectral Features')

  end  #sectionI


	def build_spectral_features_table(spectral_type_in, table_title)
    text("<b>#{table_title}</b>", :size => 10, :inline_format => true)
		arr_sf_table     = Array.new
    arr_table_header = Array.new
    arr_table_header = ['Seq #', 'Spec-trum #', 'Elem-ent', 'Peak Transition', 'Peak Energy (eV)', 'Peak FWHM', 'Peak Amplitude', 'Peak Sensitiv-ity', 'Concen-tration', 'Peak Assign-ment', 'Peak Assignment Comment']
    arr_sf_table.push( arr_table_header ) 
    spectral_feat_list = SpectralFeature.find(:all, :conditions => ["submission_id = ? and spectral_type = ?", @session[:submiss_id], spectral_type_in])
		spectral_feat_list.each do |spectral_feat|
			spectral_feat_field_list = get_html_form_fields('spectral_features', spectral_feat, @session[:show_help])
			arr_sf_rec = Array.new
			spectral_feat_field_list.each do |sff|
				arr_sf_rec.push(sff.field_data)
			end  # do
      arr_sf_table.push(arr_sf_rec)
    end    
    table(arr_sf_table, {:header => true, :cell_style => {:size => 9, :align => :left}, :column_widths => [27, 32, 36, 54, 48, 48, 54, 42, 45, 45, 90] }) do
      column(4).style :align => :right
      column(5).style :align => :right
      column(6).style :align => :right
      column(7).style :align => :right
      column(8).style :align => :right
      row(0).style :align => :center, :font_style => :bold   # center & bold the table header
    end    
  end


  def calc_author_groups
    # calculate a comma-seperated list of authors grouped by institution in seqnum order
    @ag_list = Array.new
    name_acc = Array.new
    org = ''
    authors_list = Author.find(:all, :conditions => ["submission_id = ?", @session[:submiss_id]], :order => "seqnum")

    if authors_list.blank?
    	return nil
    end

    prev_org = concat_author_fields(authors_list[0])
    authors_list.each{|author|
      if concat_author_fields(author) == prev_org
        name_acc << calc_author_name(author)   # author.fname + ' ' + author.lname
        org = concat_author_fields(author)
        # logger.warn('org value = ' + org)
      else
        # logger.warn("org value in else = #{org}")
        ag = AuthorGroupRec.new(name_acc.join(', '), org)
        @ag_list.push(ag)
        prev_org = concat_author_fields(author)
        name_acc.clear
        name_acc << calc_author_name(author)   # author.fname + ' ' + author.lname
        org = ''
        org = concat_author_fields(author)
      end
    }
    ag = AuthorGroupRec.new(name_acc.join(', '), org)
    @ag_list.push(ag)

    return @ag_list

  end  # calc_author_groups()


	# added 1/7/2009 17:21  -  should this go in the Author model ???JL
	def calc_author_name(author_rec)
		if author_rec.corresponding_author.to_s.upcase == 'Y' || author_rec.corresponding_author == '1' || author_rec.corresponding_author.to_s.upcase == 'YES'
			author_rec.fname + ' ' + author_rec.lname + " (CORRESPONDING AUTHOR, #{author_rec.email})"
		else
			author_rec.fname + ' ' + author_rec.lname
		end

	end  # calc_author_name()


	def concat_author_fields(rec)
    auth_arr = Array.new
    if rec.organization_name != '' then auth_arr.push(rec.organization_name) end
    if rec.department_name != ''   then auth_arr.push(rec.department_name) end
    if rec.address1 != ''          then auth_arr.push(rec.address1) end
    if rec.address2 != ''          then auth_arr.push(rec.address2) end
    if rec.city != ''              then auth_arr.push(rec.city) end
    if rec.state != ''             then auth_arr.push(rec.state) end
    if rec.postal_code != ''       then auth_arr.push(rec.postal_code) end
    if rec.country != ''           then auth_arr.push(rec.country) end
    return auth_arr.join(', ')
  end


  class AuthorGroupRec
    attr_reader :name_string, :org_string
    def initialize(name_string, org_string)
      @name_string  = name_string
      @org_string   = org_string
    end
  end


	def format_publisher_info(reference)
    arr = Array.new
    if !reference.publisher.blank?
      arr.push(reference.publisher)
    end
    
    if !reference.publisher_city.blank?
      arr.push(reference.publisher_city)
    end
    
    if !reference.year_published.blank?
      arr.push(reference.year_published)
    end

    if arr.size > 0
      return "(#{arr.join(', ')})"
    else
      return ''
    end  
    
  end   #format_publisher_info()


end
