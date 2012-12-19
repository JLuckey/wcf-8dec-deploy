class SubmissionController < ApplicationController

  include ApplicationHelper
  
	helper :submission

	before_filter :check_new, :except => [:new, :show_my, :show, :on_field_change]  # this code & application.rb is used to implement the AutoSave functionality

	skip_before_filter :authorize, :only => [:general_info, :phi_xps_instruments]

	skip_before_filter :check_submiss_status,
		:only => [:submiss_locked, :show_my, :show, :general_info,
							:do_submiss_summ, :submiss_summ_pdf, :show_submiss_proof_file, # These are actions in
							:get_file_status, :send_submiss_proof_file,                    #  the Submission Summary (Proof) call chain
							:list_submiss_dump, :admin_edit, :update_admin_edit,
							:dump_submiss, :new, :on_field_change, :phi_xps_instruments]

	def index
    list
    render :action => 'list'
  end
# de-cruft this stuff
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :destroy, :create, :update ],
#         :redirect_to => { :action => :show_my }

  def list
#    @submission_pages, @submissions = paginate :submissions, :per_page => 10
  end

  def show
#    3 Cases:
#    1. user has not touched new record                   :new_rec_id = nil & params[:id] = * New *
#         msg user to please enter title
#    2. user has touched new record (ie entered a title)  :new_rec_id <> nil & params[:id] = * New *
#         show new record
#    3. user wants to show existing record                :new_rec_id = dont care & params[:id] is numeric
#         show existing record using standard technique

    if params[:id] == '* New *'
      if session[:new_rec_id]
        @submission = Submission.find(session[:new_rec_id])
      else
        check_new()
      end
    else        # assuming that params[:id] numeric and a valid id for an existing Submission
      if is_member_of(params[:id])
        @submission = Submission.find(params[:id])
        session[:submiss_id]     = params[:id]
        session[:submiss_title]  = @submission.title
        # session[:technique]      = @submission.technique
				session[:submiss_status] = @submission.submiss_status    # for display in submiss_nav_tree
				if @submission.revision_num > 0                         # ???JL refactor this functionality into a method
  				session[:id_and_rev] = "#{@submission.parent_id}-#{@submission.revision_num}"
				else
					session[:id_and_rev] = "#{@submission.parent_id}"
				end
      end
    end

    @show_nav_bar = true
    update_instr_info_in_tv()  #???JL
  end  #show


  def new
    session[:submiss_id]     = '* New *'
    session[:id_and_rev]     = '* New *'
    session[:submiss_title]  = '* New Submission *'
    session[:arr_instr_info] = []
    session[:new_rec_id]     = nil
    load_listboxes
    @submission = Submission.new
    @edit_new_flag = 'New'
    @show_nav_bar  = true
    @field_list = get_html_form_fields('submissions', @submission, session[:show_help])
    render(:layout => 'submission', :template => 'submission/edit')
  end

  def create
    # Create new Submission record with data from changed field
    @submission = Submission.new(params[:field_name] => params[:field_value])
		@submission.save
		@submission.parent_id      = @submission.id
		@submission.revision_num   = 0
		@submission.submiss_status = 'new'
		@submission.save

    # Update SubmissUser table w/ this submission & user's id
    new_submiss_auth               = SubmissUser.new
    new_submiss_auth.submission_id = @submission.id
    new_submiss_auth.user_id       = session[:user_id]
    new_submiss_auth.submiss_admin = true
		new_submiss_auth.save

# Disabled this code 4/19/09 2:02 PM to fix new subm creation bug - see DevNotes TaskID 190 for more info
  # Update SubmissUser table w/ this submission & admin's id
#    new_submiss_auth               = SubmissUser.new
#    new_submiss_auth.submission_id = @submission.id
#    new_submiss_auth.user_id       = 2			# User id for admin
#    new_submiss_auth.submiss_admin = true
#    new_submiss_auth.save

    # Update Session vars
    session[:new_rec_id]    = @submission.id
    session[:submiss_id]    = @submission.id   # grep for this to confirm that id_and_rev is also being set  4/27/09 3:43 PM
    session[:id_and_rev]    = @submission.id
    session[:submiss_title] = @submission.title
  end

  def edit
    if is_member_of(params[:id])
      @submission = Submission.find(params[:id])
      load_listboxes
      @edit_new_flag = 'Editing'
      @show_nav_bar  = true
      @field_list = get_html_form_fields('submissions', @submission, session[:show_help])
      render(:layout => 'submission')
    end

  end

  def save_after_edit
    if is_member_of(session[:submiss_id])
      submission = Submission.find(session[:submiss_id])
      submission.update_attributes(params[:submission])
      submission.save
      # render(:action => 'show', :id => :submiss_id)
      redirect_to({:action => 'show', :id => session[:submiss_id]})
    end
  end

  def update(submiss_id)
    if is_member_of(submiss_id)
      @submission = Submission.find(submiss_id)
      @submission.update_attribute(params[:field_name], params[:field_value] )
    end
  end

  def destroy
    if is_member_of(params[:id])
      Submission.find(params[:id]).destroy
      redirect_to(:action => 'show_my')
    end
  end


  def show_my
  	if session[:user_role] == 'admin'
      @submission = Submission.find_all_by_delete_flag(nil).sort_by{|s| [s.parent_id, s.revision_num]}
		else
#      if session[:show_splash] != 'N'   # u.show_splash == 'y'
#        session[:show_splash] = false;
#        render('account/show_splash') and return
#      end
	    @submission = User.find(session[:user_id]).submissions.find_all_by_delete_flag(nil).sort_by{|s| [s.parent_id, s.revision_num]}
  	end

    @show_nav_bar = false
    render(:action => 'list')
  end  # show_my


  def toggle_help_text
    if session[:show_help] == 'checked'
      session[:show_help] = ''
    else
      session[:show_help] = 'checked'
    end
    render(:nothing => true)

  end


  def load_listboxes
    @spectral_category_choices = Lookup.get_listbox_choices('submissions', 'spectral_category')
    @pub_auger_deriv_choices   = Lookup.get_listbox_choices('submissions', 'pub_auger_deriv')
		@technique_choices         = Lookup.get_listbox_choices('submissions', 'technique')
  end

#  def list_Submissions    # this is never called apparently 12/13/2007 15:50 JL
#    @show_nav_bar = true
#    @Submissions = Submission.find(session[:submiss_id]).Submissions
#    render(:layout => 'submission', :template => 'Submission/list2')
#  end

#  def show_Submission
#    @show_nav_bar = true
#    @Submission = Submission.find(params[:id])
#    render(:layout => 'submission', :template => 'Submission/show')
#  end

  def list_users
    @show_nav_bar = true
    begin
      @users = Submission.find(session[:submiss_id]).users
    rescue ActiveRecord::RecordNotFound
      @users = []
    end
    render(:layout => 'submission', :template => 'user/list2')
  end

  def list_all_users
    @show_nav_bar = true
    @users = User.find(:all)
    render(:layout => 'submission', :template => 'user/list3')
  end

  def invite_user
    # 1. see if email already exists in user table  - handled in the model
    # 2. get submission#, submission title, invitor name for invitation email text
    # 3. create a new user record and get user_id and validation code for invitation email
    # 4. send invitation email

    if request.post?
      @iu = InviteeUser.new(params[:iu])
      @iu.role = 'author'
      if @iu.save
        # associate this user with this submission by updating the submiss_user table
#        SubmissUser.create(:submission_id => session[:submiss_id], :user_id => @iu.id, :submiss_admin => 'N')
#        UserNotifier.deliver_invitation(@iu, session[:submiss_id], session[:user_id])
        @show_nav_bar = true
        render(:layout => 'submission', :text => "<pre> Your invitation has been sent </pre>")
#  This code is for testing.  It does not send an email, just displays email in browser  5/3/2007 14:44 JL
#          email = UserNotifier.create_invitation(@iu, session[:submiss_id], session[:user_id])
#          render(:text => "<pre>" + email.encoded + "</pre>")
        else
          @show_nav_bar = true
          render(:layout => 'submission', :template => 'user/invite')
        end
    else  # if request is not HTML Post then just show empty form
      @show_nav_bar = true
      render(:layout => 'submission', :template => 'user/invite')
    end

  end  # invite_user()


  def select_user
    SubmissUser.create(:submission_id => session[:submiss_id], :user_id => params[:id], :submiss_admin => 'N')
    list_users()
  end  # select_user


	def no_help_msg
		render(alert("no help available yet"))
	end

  def on_field_change
		logger.error('what the heck!')
		super
  end


	def general_info()
	end  # general_info()

	def phi_xps_instruments()
	end  # phi_xps_instruments()


  def list_submiss_dump
    @show_nav_bar = false
		if params[:field_value] == '1'
  		@submissions = Submission.find(:all).sort_by{|s| [s.parent_id, s.revision_num]}
		else
		  @submissions = Submission.find_all_by_delete_flag(nil).sort_by{|s| [s.parent_id, s.revision_num]}
		end
	end


	def refresh_admin_submiss_list()
		if params[:field_value] == '1'
  		@submissions = Submission.find(:all).sort_by{|s| [s.parent_id, s.revision_num]}
		else
		  @submissions = Submission.find_all_by_delete_flag(nil).sort_by{|s| [s.parent_id, s.revision_num]}
		end
		render(:partial => 'submiss_list_admin')

	end  # refresh_admin_submiss_list()


  def dump_submiss  # What about security for this method? 10/7/2008 18:00
		if session[:user_role] != 'admin'
			redirect_to(:controller => 'submission', :action => 'show_my')
			return
		end
		# manage target directory   /usr/apps/submiss_dumps/submiss_id#
    # if submiss_id# dir already exists
    #   delete all files in it
    # else
    #   create new submiss_id# subdir
    # end
    dir = "/usr/apps/submiss_dumps/#{params[:id]}"
    if File.directory?(dir)
      Dir.foreach(dir) {|x|
        fullname = dir + '/' + x
        File.delete(fullname) unless (fullname == dir + '/.' or fullname == dir + '/..')
			}
    else
      Dir.mkdir(dir)
    end

    # perform data dump
    myFile = File.new(dir + '/' + params[:id] + '_dump.txt', 'w')

    # Dump Submission record
    submission_list = Submission.find(params[:id])
    writer([submission_list], myFile, 'submissions')

    author_list = Author.find(:all, :conditions => "submission_id = #{params[:id]}")
    writer(author_list, myFile, 'authors')

    instr_list = Instrument.find(:all, :conditions => "submission_id = #{params[:id]}")
    for instr in instr_list
      writer([instr], myFile, 'instruments')
      parmset_list = Paramset.find_all_by_instrument_id(instr.id)
      writer(parmset_list, myFile, 'paramsets')
    end

    specimen_list = Specimen.find(:all, :conditions => "submission_id = #{params[:id]}")
    writer(specimen_list, myFile, 'specimens')

# Spectra
#   SpectralFeatures
#   NamedPeaks
#   ExpVariables

# Records from these tables are written to the output file in a sequence based on
#  their hierarchy shown above.  For example:
#    First Spectra rec
#    SpectralFeatures rec(s) (children of current Spectra rec)
#    NamedPeaks rec(s)       (     "                         )
#    ExpVariables rec(s)
#    Second Spectra rec
#    SpectralFeatures rec(s) (children of current Spectra rec)
#    NamedPeaks rec(s)       (     "                         )
#    ExpVariables rec(s)
#    Third Spectra rec
#    etc...

    # Dump all Spectra records for given Submission id
    spectra_list = Spectrum.find(:all, :conditions => "submission_id = #{params[:id]}")
    for spectrum in spectra_list
      writer([spectrum], myFile, 'spectra')
      sp_feat_list = SpectralFeature.find_all_by_spectrum_id(spectrum.id)
      for sp_feat in sp_feat_list
        writer([sp_feat], myFile, 'spectral_features')
      end

      np_list = NamedPeak.find_all_by_spectrum_id(spectrum.id)
      for np in np_list
#        writer([np], myFile, 'named_peaks')
        for obj in [np]
          myFile.puts("[-named_peaks-]")
          for field in obj.attributes.keys
            myFile.puts(field + '||' + obj.send(field).to_s)
          end
          myFile.puts('parent_spectra_seqnum' + '||' + spectrum.seqnum.to_s)
          myFile.puts('submission_id' + '||' + params[:id])
          myFile.puts('[-EOR-]')
        end
      end

# ExpVariables not yet implemented in WECF - see TaskID 111 for this project for more info
#      ev_list = ExpVariable.find_all_by_spectrum_id(spectrum.id)
#      for ev in ev_list
##        writer([ev], myFile, 'exp_variables') # Taking control of writing process (below) so that the parent
#                                               #  spectrum's seqnum can be written written w/ the exp_variables
#                                               #  record to facilitate import into the different structure of
#                                               #  the Paradox database.  See marker #1 below
#                                               #  A bit of a kludge, but we only need it here   - JL 11/30/2007 13:03
#        for obj in [ev]
#          myFile.puts("[-exp_variables-]")
#          for field in obj.attributes.keys
#            myFile.puts(field + '||' + obj.send(field).to_s)
#          end
#          myFile.puts('parent_spectra_seqnum' + '||' + spectrum.seqnum.to_s)   # <--- #1
#          myFile.puts('[-EOR-]')
#        end
#      end

    end  # for spectrum..

    sftu_list = SpectralFeatTblUnit.find(:all, :conditions => "submission_id = #{params[:id]}")
    writer(sftu_list, myFile, 'spectral_feat_tbl_units')

    min_el_list = MinorElement.find(:all, :conditions => "submission_id = #{params[:id]}")
    writer(min_el_list, myFile, 'minor_elements')

    maj_el_list = MajorElement.find(:all, :conditions => "submission_id = #{params[:id]}")
    writer(maj_el_list, myFile, 'major_elements')

    sub_ref_list = SubmissionReference.find(:all, :conditions => "submission_id = #{params[:id]}")
    for sub_ref in sub_ref_list
      writer([sub_ref], myFile, 'submission_references')
      ra_list = ReferenceAuthor.find_all_by_submission_reference_id(sub_ref.id)
      writer(ra_list, myFile, 'reference_authors')
    end

    kw_list = Keyword.find(:all, :conditions => "submission_id = #{params[:id]}")
    writer(kw_list, myFile, 'keywords')

    am_list = AnalysisMethod.find(:all, :conditions => "submission_id = #{params[:id]}")
    writer(am_list, myFile, 'analysis_methods')

    af_list = AdditionalFile.find(:all, :conditions => "submission_id = #{params[:id]}")
    writer(af_list, myFile, 'additional_files')

    myFile.close

		# Status update no longer required (per Task# 207) :: disabling following code  7/13/10 4:36 PM  JL
    # update Submission's status
#		s = Submission.find(params[:id])
#		s.submiss_status      = 'exported'
#		s.submiss_status_date = Time.now.to_s(:db)
#		s.save!

    redirect_to(:action => 'list_submiss_dump')
  end  # dump_submiss()


  def writer(objlist, outFile, tblName)
    for obj in objlist
      outFile.puts("[-#{tblName}-]")
      for field in obj.attributes.keys
        col = obj.column_for_attribute(field)
        if col.type.to_s == 'binary'
          write_blob_file(obj, field, outFile)
        else
          outFile.puts(field + '||' + obj.send(field).to_s)
        end
      end
      outFile.puts('[-EOR-]')
    end
  end   # writer()


  def write_blob_file(obj, blob_field, dump_file)
    # hash contains blob field name & the name of the field that contains the blob's file name
    blob_field_hash = {'data_file' => 'data_filename', 'figure_img_file' => 'figure_img_filename', 'additional_data_file' => 'additional_file_name'}

    file_name_field = blob_field_hash.fetch(blob_field, 'not_found')
    if file_name_field != 'not_found'
      if obj.send(file_name_field) != nil
        dump_file.puts(blob_field + "||*** BLOB data - written to file: #{obj.send(file_name_field)} ***" )
        file_name_col = obj.column_for_attribute(file_name_field)
        puts "writing data file: #{obj.send(file_name_field)}"
        full_file_name = File.dirname(dump_file.path) + '/' + obj.send(file_name_field)
        blob_file = File.new(full_file_name, 'wb')
        blob_file.print(obj.send(blob_field))
        blob_file.close
      else
        dump_file.puts(blob_field + "||*** BLOB data - field is empty ***" )
      end
    else
      logger.error("***** Blob Field: #{blob_field} is not handled by this program. (update blob_field_hash in write_blob_file())")
    end

  end   # write_blob_file()

  class AuthorGroupRec
    attr_reader :name_string, :org_string
    def initialize(name_string, org_string)
      @name_string  = name_string
      @org_string   = org_string
    end
  end


  def submiss_summary
#    submiss_summary_main

		@submiss = Submission.find(session[:submiss_id])
    @author_group_list  = calc_author_groups

    keywords_list = Keyword.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]], :order => "seqnum")
    @kw_string = build_cs_str(keywords_list, 'keyword')

    major_elements_list = MajorElement.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]], :order => "seqnum")
    @maj_element_string = build_cs_str(major_elements_list, 'major_element_name')

    minor_elements_list = MinorElement.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]], :order => "seqnum")
    @min_element_string = build_cs_str(minor_elements_list, 'minor_element_name')

    @specimens_list = Specimen.find(:all, :conditions => ["submission_id = ? and include_in_journal = 'y'", session[:submiss_id]], :order => "seqnum")

    @instruments_list = Instrument.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]])

    @analysis_methods_list = AnalysisMethod.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]])

    @paramsets_list = Paramset.find(:all, :conditions => ["instrument_id = ?", 1])  # ???JL fix query to get paramsets 2/22/2008 17:27

    @submiss_references_list = SubmissionReference.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]])

    @spectral_features_list = SpectralFeature.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]])

    @spectra_list = Spectrum.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]])

    render(:layout => 'submission', :template => 'submission/submiss_summary')

  end  # submiss_summary()


  def calc_author_groups
    # calculate a comma-seperated list of authors grouped by institution in seqnum order
    @ag_list = Array.new
    name_acc = Array.new
    org = ''
    authors_list = Author.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]], :order => "seqnum")

    if authors_list.blank?
    	return nil
    end

    prev_org = concat_author_fields(authors_list[0])
    authors_list.each{|author|
      if concat_author_fields(author) == prev_org
        name_acc << calc_author_name(author)   # author.fname + ' ' + author.lname
        org = concat_author_fields(author)
        logger.warn('org value = ' + org)
      else
        logger.warn("org value in else = #{org}")
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


	def get_host_matl_character(spec)
  	a = Array.new
  	if spec.homogeneity     					!= '' then a.push(spec.homogeneity) end
  	if spec.crystallinity   					!= '' then a.push(spec.crystallinity) end
  	if spec.phase           					!= '' then a.push(spec.phase)  end
  	if spec.material_family 					!= '' then a.push(spec.material_family) end
  	if spec.electrical_characteristic != '' then a.push(spec.electrical_characteristic) end
  	if spec.special_material_classes  != '' then a.push(spec.special_material_classes) end
  	a.join('; ')

	end  # get_host_matl_character()

  # ???JL pulled up to application_helper 
  # def build_cs_str(list, field_name)    # build comma-separated string
  #   arr = Array.new
  #   list.each{ |x| arr.push(x[field_name]) }
  #   return arr.join(', ')
  # end

	# def dorf(data_object, field_name)    # "Data or Field name"
	# 	if data_object.attributes[field_name].blank?
	# 		""                         #"[*#{field_name}*]"
	# 	else
	# 		data_object.attributes[field_name]
	# 	end
	# end  # dorf()


  # def format_publisher_info(reference)
  #   arr = Array.new
  #   if !reference.publisher.blank?
  #     arr.push(reference.publisher)
  #   end
    
  #   if !reference.publisher_city.blank?
  #     arr.push(reference.publisher_city)
  #   end
    
  #   if !reference.year_published.blank?
  #     arr.push(reference.year_published)
  #   end

  #   if arr.size > 0
  #     return "(#{arr.join(', ')})"
  #   else
  #     return ''
  #   end  
    
  # end   #format_publisher_info()


	def send_submiss_proof_file()
		send_file(session[:sub_proof_file_name])
  end  # send_submiss_proof_file()


	def get_file_status()
		@file_name = session[:sub_proof_file_name]
		@submiss_proof_file_name = ''
		@submiss_proof_file_date = ''
		if File.exist?(@file_name)
			@submiss_proof_file_name = File.basename(@file_name)
  		@submiss_proof_file_date = File.mtime(@file_name).to_s(:db)
  		render(:text => "#{@submiss_proof_file_name} &nbsp&nbsp&nbsp&nbsp #{@submiss_proof_file_date}")
		else
	  	render(:text => '')
		end

	end  # get_file_status()


	def show_submiss_proof_file()
    @show_nav_bar = true
	end  # show_submiss_proof_file()


	def get_submiss_proof_pdf_name()
		return "public/pdf/submiss-#{session[:submiss_id]}-proof-u#{session[:user_id]}.pdf"
	end  # get_submiss_proof_pdf_name()


  #	1. delete existing submiss_proof pdf (if any)
	#	2. start processing for new pdf with a "Spawned" process
	#	3. render "File Download" page which contains javascript which will poll for appearance of file
	#	4. write new submiss_proof pdf file to pdf directory w/ name: submiss_999_proof_u999.pdf
	def do_submiss_summ()

		@show_nav_bar = true

#		redirect_to(:action => :show_submiss_proof_file)
    # render(:template => 'submission/show_submiss_proof_file')
		session[:sub_proof_file_name] = get_submiss_proof_pdf_name()

		if File.exist?(session[:sub_proof_file_name])
		  File.delete(session[:sub_proof_file_name])
		end
#		spawn do               # Disable the spawn code for running under Windows
		  submiss_summ_pdf2()
#		end
#  	append_figure_pdfs()
   
	end  # do_submiss_summ()


  def submiss_summ_pdf2
    submiss = Submission.find(session[:submiss_id])
    pdf9    = SubmissionProofPdf.new(submiss, session)
    send_data pdf9.render, filename:    "PdfTest10.pdf",
                           type:        "application/pdf",
                           disposition: "inline"
  end


  def submiss_summ_pdf()

    require 'pdf/writer'
		require 'pdfwriter_extensions'
		require 'pdf/simpletable'

    pdf = PDF::Writer.new
		pdf.margins_pt(36, 36, 54, 36)

		logger.info( "\n*** DCS-DEBUG --> #{Time.now} - Start PDF processing")


		# Page Numbering
		# pdf.start_page_numbering(300, 18, 9, :center, nil, 1)

		# Document Title
		# pdf.select_font("Helvetica")
  #   pdf.text('<b>Surface Science Spectra</b>', :font_size => 18)
  #   pdf.text("WCF Submission #{submiss.id} Proof #{submiss.sss_ms_num.blank? ? '' : ' - SSS Submission # ' + submiss.sss_ms_num} ", :font_size => 16)
  #   pdf.line(pdf.left_margin, pdf.y - 8 , 7.5 * 72, pdf.y - 8)
  #   pdf.stroke
  #   pdf.text(' ')

		# # Page Footer
		# pdf.open_object do |footing|
		#   pdf.save_state
		#   pdf.stroke_color! Color::RGB::Black
		#   pdf.stroke_style! PDF::Writer::StrokeStyle::DEFAULT

		#   s = 7
		#   t = "Surface Science Spectra #{submiss.sss_ms_num.blank? ? '' : ' - Submission # ' + submiss.sss_ms_num} "   #submiss.title.size > 60 ? (submiss.title[0..60] + ' ...') : submiss.title
		#   x = pdf.absolute_left_margin
		#   y = pdf.absolute_bottom_margin
		#   pdf.add_text(x, 20, t, s)
		# 	pdf.add_text(pdf.absolute_right_margin - 76, 20, 'www.PublishInSSS.com', s)

		#   x = pdf.absolute_left_margin
		#   w = pdf.absolute_right_margin
		#   y += (pdf.font_height(s) * 1.05)
		#   pdf.line(x, 30, w, 30).stroke

		#   pdf.restore_state
		#   pdf.close_object
		#   pdf.add_object(footing, :all_pages)
		# end  # Page Footer


# 		# Page Header
# 		pdf.open_object do |header|
# 		  pdf.save_state
# 		  pdf.stroke_color! Color::RGB::Black
# 		  pdf.stroke_style! PDF::Writer::StrokeStyle::DEFAULT

# 			s = 7
# 		  title = submiss.title.size > 60 ? (submiss.title[0..60] + '...') : submiss.title
# 			t = "#{title}  (WCF ID #{submiss.id})"
# 		  x = pdf.absolute_left_margin
# 		  y = pdf.absolute_top_margin
# 		  pdf.add_text(x, y, t, s)
# 			pdf.add_text(pdf.absolute_right_margin - 66, y, Time.now.to_s(:db), s)

# 		  lm = pdf.absolute_left_margin
# 		  rm = pdf.absolute_right_margin
# 		  y += (pdf.font_height(s) - 11 )
# 		  pdf.line(lm, y, rm, y).stroke
# #			pdf.add_text(pdf.absolute_left_margin, y - 10, 'spacer', s)

# 		  pdf.restore_state
# 		  pdf.close_object
# 		  pdf.add_object(header, :all_following_pages)
# 		end  # Page Header

  #   pdf.text('<b>' + submiss.title + '</b>', :font_size => 14)

  #   # --  Authors section --
		# pdf.select_font("Times-Roman")
		# pdf.text('', :font_size => 10)
		# author_group = calc_author_groups()
  #   if !author_group.blank?
	 #    author_group.each do |ag|
	 #      pdf.text(ag.name_string)
	 #      pdf.text('<i>' + ag.org_string + '</i>')
	 #      pdf.text(' ')
	 #  	end
	 #  else
		# 	pdf.text('Authors Section does not contain any data')
		# 	pdf.text(' ')
	 #    pdf.text(' ')
	 #    pdf.text(' ')
  #   end

		# logger.info( "\n*** DCS-DEBUG --> #{Time.now} - qry Submission")

		# submission = Submission.find(session[:submiss_id])
  # 	submission_field_list = get_html_form_fields('submissions', submission, session[:show_help])
		# submission_field_list.delete_at(0)    # Removing the Submission Title from this listing because it is already shown above
		# submission_field_list.each do |ifl|
		# 	# adjust formatting for entries like sub-headings which don't have a leading Field Designator (like A-3b.)
		# 	form_id_val = ifl.contrib_form_id.blank?  ? '' : ifl.contrib_form_id + '  '
		# 	pdf.text("<b>#{form_id_val}#{ifl.field_label} </b> #{ifl.field_data}")
  #   	pdf.text(' ')
		# end
		# pdf.text(' ')
  #   pdf.text(' ')

		# logger.info( "\n*** DCS-DEBUG --> #{Time.now} - qry Keyword")

		# keywords_list = Keyword.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]], :order => "seqnum")
  #   kw_string = build_cs_str(keywords_list, 'keyword')
  #   pdf.text('<b>Keywords: </b> ' + kw_string)
  #   pdf.text(' ')

		 # logger.info( "\n*** DCS-DEBUG --> #{Time.now} - qry MajorElement")

    # major_elements_list = MajorElement.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]], :order => "seqnum")
    # maj_element_string = build_cs_str(major_elements_list, 'major_element_name')
    # pdf.text('<b>Major Elements in Spectrum: </b> ' + maj_element_string )
    # pdf.text(' ')

    # minor_elements_list = MinorElement.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]], :order => "seqnum")
    # min_element_string = build_cs_str(minor_elements_list, 'minor_element_name')
    # pdf.text('<b>Minor Elements in Spectrum: </b> ' + min_element_string)
    # pdf.text(' ')
    # pdf.text(' ')

		# Submission References
# 		pdf.text('<b>SECTION A - REFERENCES</b>')
#     pdf.line(pdf.left_margin, pdf.y - 8 , 7.5 * 72, pdf.y - 8)
#     pdf.stroke
#     pdf.text(' ')

# 		reference_list = SubmissionReference.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]], :order => 'seqnum')
# 		if reference_list.size > 0
# 			reference_list.each do |reference|

# 		logger.info( "\n*** DCS-DEBUG --> #{Time.now} - qry ReferenceAuthor")

# 				reference_authors_list = ReferenceAuthor.find(:all, :conditions => ["submission_reference_id = ?", reference.id], :order => 'seqnum')
# 				author_arr = Array.new
# 				reference_authors_list.each do |author|
# 					author_arr.push("#{author.fname} #{author.lname}")
# 				end  # reference_authors_list
# 				pdf.text("<b>Reference #:</b> #{reference.seqnum}")
# 				pdf.text("  <b>Authors:</b> #{author_arr.join(', ')}")

# 				case reference.pub_type.downcase
# 					when 'journal'
#   					pdf.text("  #{dorf(reference, 'title')} #{dorf(reference, 'volume')}, #{dorf(reference, 'pages')} (#{dorf(reference, 'year_published')})")

#           when 'book'
#   					pdf.text("  " +
#                      dorf(reference, 'title')         + ' ' +
#                      dorf(reference, 'edition')       + ' ' +
#                      format_publisher_info(reference) + ' ' +
#                      dorf(reference, 'chapter')       + ' ' +
#                      dorf(reference, 'pages') )
                 
#   				else  # 'other' pub_type
#  	  				pdf.text("  #{dorf(reference, 'title')} #{format_publisher_info(reference)} #{dorf(reference, 'chapter')} #{dorf(reference, 'pages')}")
# 				end

# #				reference_field_list = get_html_form_fields('submission_references', reference)
# #				reference_field_list.each do |ifl|
# #					form_id_val = ifl.contrib_form_id.blank?  ? '' : ifl.contrib_form_id + '  '
# #					pdf.text("<b>#{form_id_val}#{ifl.field_label} </b> #{ifl.field_data}")
# #    			pdf.text(' ')
# #				end  # reference_field_list
#   			pdf.text(' ')
# 			end  # reference_list
# 		else
# 			pdf.text('Reference Section does not contain any data')
# 		end
# 		pdf.text(' ')
# #		pdf.text('*Note: Entries showing [* *] indicate Reference fields that were left blank. ')

# 		pdf.text(' ')
#     pdf.text(' ')
#     pdf.text(' ')


#		sub_ref_list = SubmissionReference.find(:all, :conditions => "submission_id = session[:submiss_id]")
#    for sub_ref in sub_ref_list
#      writer([sub_ref], myFile, 'submission_references')
#      ra_list = ReferenceAuthor.find_all_by_submission_reference_id(sub_ref.id)
#			reference_string = build_cs_str(ra_list, 'lname')
#			reference_string = reference_string
##			writer(ra_list, myFile, 'reference_authors')
#    end


	# 	# Specimen Section - note: there can be multiple Specimens
	# 	pdf.text('<b>SECTION B - SPECIMEN DESCRIPTION</b>')
 #    pdf.line(pdf.left_margin, pdf.y - 8 , 7.5 * 72, pdf.y - 8)
 #    pdf.stroke
 #    pdf.text(' ')

 # logger.info( "\n*** DCS-DEBUG --> #{Time.now} - qry Specimen")

	# 	specimens_list = Specimen.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]], :order => "seqnum")
	# 	if specimens_list.size > 0
	# 		specimens_list.each do |specimen|
	# 			specimen_field_list = get_html_form_fields('specimens', specimen, session[:show_help])
	# 			specimen_field_list.each do |ifl|
	# 				form_id_val = ifl.contrib_form_id.blank?  ? '' : ifl.contrib_form_id + '  '
	# 				pdf.text("<b>#{form_id_val}#{ifl.field_label} </b> #{ifl.field_data}")
 #    			pdf.text(' ')
	# 			end
	# 		end
	# 	else
	# 		pdf.text('Specimen Section does not contain any data')
	# 	end
	# 	pdf.text(' ')
 #    pdf.text(' ')
 #    pdf.text(' ')


# 		# Instrument Section
# 		pdf.text('<b>SECTION C - INSTRUMENT DESCRIPTION</b>')
#     pdf.line(pdf.left_margin, pdf.y - 8 , 7.5 * 72, pdf.y - 8)
#     pdf.stroke
#     pdf.text(' ')

# logger.info( "\n*** DCS-DEBUG --> #{Time.now} - qry Instruments")

#     instruments_list = Instrument.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]])
# 		if instruments_list.size > 0
# 			instrument_field_list = get_html_form_fields('instruments', instruments_list[0], session[:show_help])

# logger.info( "\n*** DCS-DEBUG --> #{Time.now} - Writing Instrument lines")

# 			instrument_field_list.each do |ifl|
# 				form_id_val = ifl.contrib_form_id.blank?  ? '' : ifl.contrib_form_id + '  '
# 				pdf.text("<b>#{form_id_val}#{ifl.field_label} </b> #{ifl.field_data}")
#     		pdf.text(' ')
# 			end
# logger.info( "\n*** DCS-DEBUG --> #{Time.now} - End Writing Instrument lines")
# 		else
# 			pdf.text('Instrument Section does not contain any data')
# 		end
#     pdf.text(' ')
#     pdf.text(' ')
#     pdf.text(' ')

logger.info( "\n*** DCS-DEBUG --> #{Time.now} - End qry Instruments")


		# Section D - Calibration Info   (this should go into a table)
		pdf.start_new_page
    pdf.text(' ')
    pdf.text(' ')
		pdf.text('<b>SECTION D - CALIBRATION INFORMATION</b>')
    pdf.line(pdf.left_margin, pdf.y - 8 , 7.5 * 72, pdf.y - 8)
    pdf.stroke
    pdf.text(' ')
    pdf.text(' ')
		build_spectral_features_table(pdf, 'calibration', 'Section D - Calibration Spectral Features')


		# # Section E - Variable Instrument Parameters
		# pdf.text('<b>SECTION E - VARIABLE INSTRUMENT PARAMETERS </b>')
  #   pdf.line(pdf.left_margin, pdf.y - 8 , 7.5 * 72, pdf.y - 8)
  #   pdf.stroke
  #   pdf.text(' ')

		# # 4/27/2008 20:41 query instruments by submission_id  submissions ->> spectra -> paramset
		# paramsets_list = Paramset.find(:all, :conditions => ["instrument_id = ?", session[:instrument_id]])
		# logger.info( "****** DCS-DEBUG --> Instrument ID = #{session[:instrument_id]}")
		# if paramsets_list.size > 0
		# 	paramsets_list.each do |paramset|
		# 		paramset_field_list = get_html_form_fields('paramsets', paramset, session[:show_help])
		# 		paramset_field_list.each do |pfl|
		# 			form_id_val = pfl.contrib_form_id.blank?  ? '' : pfl.contrib_form_id + '  '
		# 			pdf.text("<b>#{form_id_val}#{pfl.field_label} </b> #{pfl.field_data}")
  #   			pdf.text(' ')
		# 		end
  #   		pdf.text(' ')
  #   		pdf.text(' ')
  #   		pdf.text(' ')
		# 	end  # do
		# else
		# 	pdf.text('Variable Instrument Parameters Section does not contain any data')
		# end


# 		# Section F - Spectra - data presented in PDF tables
# #		pdf.start_new_page
# #    pdf.text(' ')
# #    pdf.text(' ')
# 		spectra_list = Spectrum.find(:all, :conditions => ["submission_id = ?", session[:submiss_id]])
# 		if !spectra_list.blank?
# 			spect_subset = Array.new
# 	  	field_list   = get_html_form_fields('submiss_summary_pdf', spectra_list[0], session[:show_help])
# 			num_of_cols  = spectra_list.size

# 			if spectra_list.size.modulo(4) > 0					# calc the number of tables reqd to show all spectra with 4 spectra cols per table
# 				tabl_count = spectra_list.size.div(4) + 1
# 			else
# 				tabl_count = spectra_list.size.div(4)
# 			end
# 			spect_count = 0
#   		col_count   = 1

# 			tabl_count.times do
# 				# create an array which holds the current subset of 4 spectra records to be printed in this table
# 				4.times do
# 					break if spect_count >= spectra_list.size
# 					spect_subset.push(spectra_list[spect_count])
# 					spect_count += 1
# 				end

# 				pdf.start_new_page
# 				pdf.text(' ')
# 				tab = PDF::SimpleTable.new
# 				tab.header_gap = 20

# 	logger.info( "\n*** DCS-DEBUG --> #{Time.now} - qry Spectra Column Processing")

# 	  		# Converting Spectra record data from rows to columns
# 				field_list.each do |field|
# 	    	  my_hash = Hash.new    # rename to row_hash?  ???JL
# 	    	  my_hash['col1'] = field.field_label			# first col contains field labels
# 	    	  i = 1
# # Refactor to use Case statement and call methods to handle cases ???JL  3/23/10 5:08 PM
# 	    	  spect_subset.each do |spec_rec|
# 						if field.field_name == 'specimen_id'    		    # need to lookup Specimen's seqnum & host values
# 							begin
# 							  specimens_rec = Specimen.find(spec_rec.attributes[field.field_name])
# 							rescue
# 	  						my_hash['Spectra' + i.to_s] = "null"
# 							else
# 								my_hash['Spectra' + i.to_s] = "#{specimens_rec.seqnum} - #{specimens_rec.host}"
# 							end
# 						elsif field.field_name == 'paramset_id'    		# need to lookup Paramset's Seqnum & Source Label values
# 							begin
#                 paramset_rec = Paramset.find(spec_rec.attributes[field.field_name])
# 							rescue
# 								my_hash['Spectra' + i.to_s] = "null"
# 							else
# 							  my_hash['Spectra' + i.to_s] = "#{paramset_rec.seqnum} - #{paramset_rec.excitation_source_label}"
# 							end

#             # JL new code for Named Peaks  7/6/10 5:33 PM
#             #  1. update field list so that get_html_form_fields returns Named Peaks
#             #  2. write code to get dependent recs from spectra ->> named_peaks
#             #  3. Refactor this whole code section into a new .rb file in the appropriate location         
#             elsif field.field_name == 'id'   # field name comes from "wecf_field_name" field in field_masters table
#               begin
#                 s = ''
#                 named_peaks_list = NamedPeak.find(:all, :conditions => ["spectrum_id = ?", spec_rec.attributes['id']], :order => 'seqnum')
#               rescue
# 								my_hash['Spectra' + i.to_s] = "null"
#               else
#                 named_peaks_list.each do |np_rec|
#                   s << "#{np_rec.species_label} #{np_rec.transition_label}, "
#                 end  # do
#                 my_hash['Spectra' + i.to_s] = s.chomp(", ")
#               end

#             else
# 						  my_hash['Spectra' + i.to_s] = spec_rec.attributes[field.field_name]
# 						end
# 	  	      i += 1
# 	    	  end  # do
# 	    	  tab.data.push(my_hash)  # This is a row in the current PDF table
# 	    	end  #do

# 			logger.info( "\n*** DCS-DEBUG --> #{Time.now} - End qry Spectra Column Processing")

# 	    	tab.column_order = ['col1', 'Spectra1', 'Spectra2', 'Spectra3', 'Spectra4']

# 	    	tab.columns["col1"] = PDF::SimpleTable::Column.new("row") do |col|
# 	    	  col.heading = 'Field Name'
# 	    	  col.width   = 72
# 				end

# 				4.times do |n|		# Calculating column headings e.g. "Spectrum 8" or "Spectrum 17"
# 					tab.columns["Spectra#{n + 1}"] = PDF::SimpleTable::Column.new("row") do |col|
# 						if col_count <= num_of_cols
# 	    				col.heading = 'Spectrum ' + (col_count).to_s
# 						else
# 	    				col.heading = ''
# 						end  # if
# 						col.heading.justification = :center
# 	    			col.width   = 120
# 					end
# 					col_count += 1
# 				end  # do

# 	    	tab.width = 72 * 8.3
# 	    	tab.font_size = 9
# 	    	tab.title = 'Section F - Spectra'
# 	    	tab.render_on(pdf)

# 				spect_subset.clear
# 			end  # do

#   	else
# 			pdf.text('<b>SECTION F - Spectra</b>')
# 	    pdf.line(pdf.left_margin, pdf.y - 8 , 7.5 * 72, pdf.y - 8)
# 	    pdf.stroke
# 	  	pdf.text(' ')
# 			pdf.text('Section F - Spectra does not contain any data')
# 		end  # if !spectra_list.blank?
#   	pdf.text(' ')
#   	pdf.text(' ')
#   	pdf.text(' ')


# 		# Section H - Analysis Methods
# 		pdf.text('<b>SECTION H - ANALYSIS METHODS</b>', :font_size => 10)
#   	pdf.line(pdf.left_margin, pdf.y - 8 , 7.5 * 72, pdf.y - 8)
#   	pdf.stroke
#   	pdf.text(' ')

# #		analysis_method = AnalysisMethod.find(:conditions => ["submission_id = ?", session[:submiss_id]])

# 	logger.info( "\n*** DCS-DEBUG --> #{Time.now} - qry AnalysisMethods")

# 		analysis_method = AnalysisMethod.find_by_submission_id(session[:submiss_id])
# 		if analysis_method
# 			analysis_method_field_list = get_html_form_fields('analysis_methods', analysis_method, session[:show_help])
# 			analysis_method_field_list.each do |amfl|
# 				form_id_val = amfl.contrib_form_id.blank?  ? '' : amfl.contrib_form_id + '  '
# 				pdf.text("<b>#{form_id_val}#{amfl.field_label} </b> #{amfl.field_data}")
#   	  	pdf.text(' ')
# 			end
# 		else
# 			pdf.text('Analysis Methods Section does not contain any data')
# 		end
#   	pdf.text(' ')
#   	pdf.text(' ')
#   	pdf.text(' ')

		# # Section I - Spectral Features
		# pdf.start_new_page
  #   pdf.text(' ')
  #   pdf.text(' ')
		# pdf.text('<b>SECTION I - Units for Spectral Features Quantitative Fields</b>')
  #   pdf.line(pdf.left_margin, pdf.y - 8 , 7.5 * 72, pdf.y - 8)
  #   pdf.stroke
  #   pdf.text(' ')

		# spectral_feat_tbl_unit = SpectralFeatTblUnit.find_by_submission_id(session[:submiss_id])
		# if spectral_feat_tbl_unit
		# 	spectral_feat_tbl_unit_field_list = get_html_form_fields('spectral_feat_tbl_units', spectral_feat_tbl_unit, session[:show_help])
		# 	spectral_feat_tbl_unit_field_list.each do |amfl|
		# 		form_id_val = amfl.contrib_form_id.blank?  ? '' : amfl.contrib_form_id + '  '
		# 		pdf.text("<b>#{form_id_val}#{amfl.field_label} </b> #{amfl.field_data}")
  #     	pdf.text(' ')
		# 	end
		# else
		# 	pdf.text('Quantitative Fields Section does not contain any data')
		# end
  # 	pdf.text(' ')

#	my_table = PDF::SimpleTable.new
#	my_data = [{'f' => 'jeff', 'l' => 'luckey'}, {'f' => 'conner', 'l' => 'luckey'}]
#	my_table.data = my_data
#	my_table.column_order = ['l', 'f']
#	my_table.width = 4 * 72
# my_table.title = 'My Fubar Fixer Table'
# my_table.render_on(pdf)

    build_spectral_features_table(pdf, 'specimen', 'Section I - Spectral Features')

#		pdf.save_as("public/pdf/submiss_summary#{session[:user_id]}.pdf")
		pdf.save_as(get_submiss_proof_pdf_name() + '-1')
#   redirect_to("#{request.relative_url_root}/pdf/submiss_summary#{session[:user_id]}.pdf")

	end  # submiss_summ_pdf()


	def build_spectral_features_table(pdf, spectral_type_in, table_title)

	# Section I (& Sect D) - Spectral Features table
		sf_table = PDF::SimpleTable.new
		sf_table.heading_font_size = 10
		sf_table.font_size         = 9
		sf_table.header_gap 			 = 20
#		sf_table.protect_rows      = 2
#		sf_table.minimum_space     = 150
#  	pdf.text(' ')

    spectral_feat_list = SpectralFeature.find(:all, :conditions => ["submission_id = ? and spectral_type = ?", session[:submiss_id], spectral_type_in])
		spectral_feat_field_list = nil
		if spectral_feat_list.size > 0
			spectral_feat_list.each do |spectral_feat|
				spectral_feat_field_list = get_html_form_fields('spectral_features', spectral_feat, session[:show_help])
				data_hash = Hash.new
				spectral_feat_field_list.each do |sff|
					data_hash[sff.field_name] = sff.field_data
					if sff.field_name == 'spectrum_id' && !sff.field_data.blank?    # need to get FK's seqnum from spectra table
						data_hash[sff.field_name] = Spectrum.find(sff.field_data).seqnum
					end
				end  # do
				sf_table.data.push(data_hash)
			end  # do

			spectral_feat_field_list.each do |sff|
				sf_table.column_order.push(sff.field_name)
			end  # do
#			sf_table.column_order.delete_at(sf_table.column_order.length - 1)

#    	sf_table.column_order = ['Spectrum ID#:', 'Seq#', 'Element:', 'Peak Transition:', 'Peak Energy (eV):',
#															 'Peak FWHM:', 'Peak Amplitude:', 'Sensitivity Factor:', 'Concentration:', 'Peak Assignment:']

			sf_table.column_order.each do |col|
				sf_table.columns[col] = PDF::SimpleTable::Column.new(col) do |new_col|
    			new_col.heading = col
    			new_col.width   = 36
				end
			end

			sf_table.columns['spectrum_id'].heading 			= 'Spec-trum #'
			sf_table.columns['spectrum_id'].heading.justification = :center
			sf_table.columns['spectrum_id'].justification = :center
			sf_table.columns['spectrum_id'].width         = 34

			sf_table.columns['seqnum'].heading 			 = 'Seq #'
			sf_table.columns['seqnum'].heading.justification = :center
			sf_table.columns['seqnum'].justification = :center
			sf_table.columns['seqnum'].width         = 30

			sf_table.columns['element'].heading = 'Element'
			sf_table.columns['element'].width   = 45

			sf_table.columns['peak_transition'].heading = 'Peak Transition'
			sf_table.columns['peak_transition'].width   = 54

			sf_table.columns['peak_energy'].heading = 'Peak Energy (eV)'
			sf_table.columns['peak_energy'].width   = 54
			sf_table.columns['peak_energy'].justification = :right

			sf_table.columns['peak_fwhm'].heading = 'Peak FWHM'
			sf_table.columns['peak_fwhm'].width   = 45
			sf_table.columns['peak_fwhm'].justification = :right

			sf_table.columns['peak_amplitude'].heading = 'Peak Ampli-tude'
			sf_table.columns['peak_amplitude'].width   = 55
			sf_table.columns['peak_amplitude'].justification = :right

			sf_table.columns['peak_sensitivity'].heading = 'Peak Sensit-ivity'
			sf_table.columns['peak_sensitivity'].width   = 45
			sf_table.columns['peak_sensitivity'].justification = :right

			sf_table.columns['concentration'].heading = 'Concen-tration'
			sf_table.columns['concentration'].width   = 45
			sf_table.columns['concentration'].justification = :right

			sf_table.columns['peak_assignment'].heading = 'Peak Assign-ment'
			sf_table.columns['peak_assignment'].width   = 54

			sf_table.columns['peak_assignment_comment'].heading = 'Peak Assignment Comment'
			sf_table.columns['peak_assignment_comment'].width   = 82


			sf_table.width 		 = 72 * 8.3
    	sf_table.title 		 = table_title
    	sf_table.render_on(pdf)
		else
			pdf.text('Spectral Features Section does not contain any data')
		end
  	pdf.text(' ')
  	pdf.text(' ')
  	pdf.text(' ')

	end  # build_spectral_features_table()

#  Processing for appending image PDFs to Submission Summary/Proof
#	 9/23/2008 10:21
#
#  Specification:
#  1. Append 0 or more image PDFs to Submission Summary in Spectrum Number order
#  2. Should include pdf file name on page - implement in subsequent development iteration
#
#  Pseudo Code:
#  1. Process Submiss_Summ w/ existing code
#  2. Generate list of Spectral Image files by querying Spectra table
#  2.1  Filter list to include only .pdf files
#  2.2  List should be in Spectrum Number order
#  3. Dump those files to dump subdir
#  3.1  Confirm all files get created
#  4. Assemble file names into a system command
#  5. Execute system command to call pdfkt to generate new Submiss Summ pdf w/ appended image PDFs

	def append_figure_pdfs
		target_dir = 'public/pdf/'
    myFile 		 = File.new(target_dir + 'sub_proof_dummy.txt', 'w')

		# Get list of image files that are PDFs
		@spectrum_with_pdf_list = Array.new
		spectrum_list = Spectrum.find_all_by_submission_id(session[:submiss_id])   # need to order by spectrum.seqnum
		for spect in spectrum_list                                                 # get only spectrum.seqnum & figure_img_filename
			if spect.figure_img_filename and (File.extname(spect.figure_img_filename).downcase == '.pdf')
				@spectrum_with_pdf_list.push(spect)		# collecting only PDF files
			end
		end

		# Write those files to the staging directory
		@file_names = ''
		for spectrum_with_pdf in @spectrum_with_pdf_list
			write_blob_file(spectrum_with_pdf, 'figure_img_file', myFile)
			@file_names = @file_names + ' ' + target_dir + "\'" + spectrum_with_pdf.figure_img_filename + "\'"
		end

#		base_name = File.dirname(get_submiss_proof_pdf_name()) + '\\' +   			# getting path & file name w/o extension
#								File.basename(get_submiss_proof_pdf_name(), '.*')
#		outfile 	= base_name[0..base_name.length - 3] + File.extname(get_submiss_proof_pdf_name())
#		outfile 	= base_name + '-with-figs' + File.extname(get_submiss_proof_pdf_name())

		# Assemble command-line to execute pdftk.exe utility to append the files to the Submission Proof
    # change JL - 2008-12-12 1700 PST remove "util" prefix (& .exe extension) on next command for Linux box
# For Win32 uncomment next line
#  	@command = 'util\pdftk.exe ' + get_submiss_proof_pdf_name() + '-1 ' + @file_names + ' cat output ' + get_submiss_proof_pdf_name() + ' dont_ask'

# For Linux uncomment next line
   @command = 'pdftk ' + get_submiss_proof_pdf_name() + '-1 ' + @file_names + ' cat output ' + get_submiss_proof_pdf_name() + ' dont_ask'

		session[:test_command] = @command

    logger.info( "\n*** DCS-DEBUG- TestCommand --> #{Time.now} - #{@command}")

		system(@command)
#		session[:command_return_code] = $?   # For Linux system return code

	end  # append_figure_pdfs

	def submiss_locked()
		@show_nav_bar = true
	end  # submiss_locked()


	def request_submit_to_sss()
		# add logic here to show user submittal instructions based upon current status  2/2/2009 11:34 - done
		@show_nav_bar = true
		s = Submission.find(session[:submiss_id])
		if s.revision_num > 0 and s.submiss_status == 'in-revision'
    	render(:layout => 'submission', :template => 'submission/request_submit_revs_to_sss')
		else
    	render(:layout => 'submission', :template => 'submission/request_submit_to_sss')
		end
	end  # request_submit_to_sss()


	def submit_to_sss()
		change_subm_status('submitted')
	end  # submit_to_sss()


	def submit_revs_to_sss()
		change_subm_status('revised-by-author')
	end  # submit_revs_to_sss()


	def change_subm_status(target_status_in)  # should this go into the Submission model ???JL 2/3/2009 10:51
		su = SubmissUser.find_by_submission_id_and_user_id(session[:submiss_id], session[:user_id])
		if su and (su.submiss_admin == '1') || (session[:user_role] == 'admin')
			u = User.find(session[:user_id])
			s = Submission.find(session[:submiss_id])
			prior_status 					= s.submiss_status
			s.submiss_status      = target_status_in
			s.submiss_status_date = Time.now.to_s(:db)
			s.save!
			UserNotifier.deliver_submiss_sent_to_sss(u, s, session[:id_and_rev], s.submiss_status, prior_status)
  		render(:layout => 'submission', :template => 'submission/submit_to_sss')
		else
			@error_txt = 'You are not the Submission Admin.  Only the Submission Administrator can Send a Submission to SSS.'
			render(:action => 'submit_to_sss_error')
  	end

	end  # change_subm_status()


	def admin_edit()
		session[:submiss_id] = params[:id]
		@submission = Submission.find(params[:id])
		@submiss_status_choices = Lookup.get_listbox_choices('submissions', 'submiss_status')
	end  # admin_edit()


	def update_admin_edit()
    if is_member_of(session[:submiss_id])
      @submission = Submission.find(params[:id])
			@submission.update_attributes(params[:submission])
		end
		redirect_to(:action => 'list_submiss_dump')
#    if @user.update_attributes(params[:user])
#    end
	end  # update_admin_edit()


	def send_downtime_emails()
		user_list = User.find(:all)
		user_list.each {|u|
			UserNotifier.deliver_downtime_notice(u.email)
		}
		render(:nothing => true)
	end  # downtime()


  def flag_for_deletion()
		s = Submission.find(session[:submiss_id])
		s.title = "*** DELETED - #{Time.now.to_s(:db)} *** #{s.title} "
		s.delete_flag = Time.now
		s.save
		redirect_to(:action => 'admin_edit', :id => s.id)
  end  # flag_for_deletion()


	private

  def is_member_of(subId)  # is user a member of submission x
    if SubmissUser.find_by_submission_id_and_user_id(subId, session[:user_id])
      return true
    elsif session[:user_role] == 'admin'
      return true
		else
      redirect_to(:action => 'show_my')
      return false
    end
  end


  def submiss_proof_pdf
    
  end

end  # SubmissionController

