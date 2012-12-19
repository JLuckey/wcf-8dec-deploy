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

