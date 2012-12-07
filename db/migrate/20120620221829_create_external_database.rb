class CreateExternalDatabase < ActiveRecord::Migration
  def up

	  create_table "additional_files", :force => true do |t|
	    t.integer  "submission_id"
	    t.string   "additional_file_name"
	    t.binary   "additional_data_file"
	    t.datetime "file_time_stamp"
	    t.text     "description"
	    t.datetime "created_on"
	  end

	  create_table "analysis_methods", :force => true do |t|
	    t.integer  "submission_id"
	    t.text     "energy_scale_correct"
	    t.text     "energy_scale_shift"
	    t.text     "intensity_scale_correct"
	    t.text     "peak_shape_background"
	    t.text     "quantitation"
	    t.datetime "updated_on"
	  end

	  create_table "article_authors", :force => true do |t|
	    t.integer  "article_references_id"
	    t.integer  "seqnum"
	    t.string   "fname",                 :limit => 40
	    t.string   "lname",                 :limit => 40
	    t.string   "mname",                 :limit => 40
	    t.datetime "updated_on"
	  end

	  create_table "article_references", :force => true do |t|
	    t.integer  "submission_id"
	    t.integer  "seqnum"
	    t.string   "article_title", :limit => 128
	    t.string   "volume",        :limit => 128
	    t.datetime "publish_date"
	    t.string   "page",          :limit => 20
	    t.string   "publisher",     :limit => 128
	  end

	  create_table "authors", :force => true do |t|
	    t.integer  "submission_id"
	    t.integer  "seqnum"
	    t.string   "honorific",            :limit => 8
	    t.string   "fname",                :limit => 40
	    t.string   "lname",                :limit => 40
	    t.string   "suffix",               :limit => 20
	    t.string   "email",                :limit => 60
	    t.string   "organization_name",    :limit => 80
	    t.string   "address1",             :limit => 40
	    t.string   "address2",             :limit => 40
	    t.string   "city",                 :limit => 40
	    t.string   "state",                :limit => 20
	    t.string   "postal_code",          :limit => 20
	    t.string   "country",              :limit => 20
	    t.string   "phone",                :limit => 20
	    t.string   "fax",                  :limit => 20
	    t.datetime "created_on"
	    t.datetime "updated_on"
	    t.string   "corresponding_author", :limit => 3
	    t.string   "department_name",      :limit => 80
	  end

	  create_table "calib_features", :force => true do |t|
	    t.integer  "seq_num"
	    t.string   "spectrum_id",                  :limit => 32
	    t.string   "element",                      :limit => 32
	    t.string   "peak_transition",              :limit => 32
	    t.string   "peak_energy",                  :limit => 32
	    t.string   "peak_energy_precis",           :limit => 32
	    t.string   "peak_fwhm",                    :limit => 32
	    t.string   "peak_fwhm_precis",             :limit => 32
	    t.string   "peak_amplitude",               :limit => 32
	    t.string   "peak_ampli_precis",            :limit => 32
	    t.string   "peak_sensitivity",             :limit => 32
	    t.string   "peak_sensit_precis",           :limit => 32
	    t.string   "concentration",                :limit => 32
	    t.string   "concentration_precis",         :limit => 32
	    t.string   "peak_assignment",              :limit => 32
	    t.text     "peak_assignment_comment"
	    t.integer  "spectral_region_num"
	    t.string   "lineitem_footnotes",           :limit => 32
	    t.string   "lineitem_footnote_marker",     :limit => 32
	    t.datetime "updated_on"
	    t.integer  "named_accession_num"
	    t.integer  "named_accession_spectrum_num"
	  end

	  create_table "exec_logs", :force => true do |t|
	    t.datetime "created_on"
	    t.integer  "user_id"
	    t.string   "controller"
	    t.string   "method"
	    t.string   "id_val"
	  end

	  create_table "exp_variables", :force => true do |t|
	    t.integer "spectrum_id",                 :default => 0, :null => false
	    t.integer "seqnum",                                     :null => false
	    t.string  "exp_var_label", :limit => 80
	    t.string  "exp_var_unit",  :limit => 20
	    t.string  "data_value",    :limit => 20
	    t.text    "comment"
	  end

	  create_table "field_masters", :force => true do |t|
	    t.string  "pdox_table"
	    t.string  "pdox_field"
	    t.string  "pdox_data_type"
	    t.integer "column_id"
	    t.string  "wecf_table_name"
	    t.string  "wecf_field_name"
	    t.string  "wecf_data_type"
	    t.text    "help_text"
	    t.integer "seq_on_wecf_page"
	    t.text    "notes"
	    t.string  "contrib_form_id"
	    t.string  "contrib_form_section"
	    t.integer "contrib_form_field_num"
	    t.string  "contrib_form_sub_field"
	    t.string  "contrib_form_prompt"
	    t.integer "field_id"
	    t.integer "data_dict_sect"
	    t.integer "data_dict_field"
	    t.integer "data_dict_sub_field"
	    t.string  "data_dict_comment"
	    t.string  "completeness_code"
	    t.string  "html_widget"
	    t.integer "html_widget_height"
	    t.integer "html_widget_width"
	    t.string  "html_color",             :limit => 45
	    t.string  "show_field",             :limit => 1
	  end

	  create_table "form_fields", :force => true do |t|
	    t.integer "forms_id",                       :default => 0, :null => false
	    t.integer "seqnum"
	    t.string  "field_label"
	    t.string  "designator",       :limit => 10
	    t.text    "help_text"
	    t.integer "field_masters_id"
	    t.string  "html_widget",      :limit => 45
	    t.integer "widget_width"
	    t.integer "widget_height"
	  end

	  create_table "forms", :force => true do |t|
	    t.string   "name"
	    t.text     "descrip"
	    t.text     "remarks"
	    t.datetime "created_on"
	    t.string   "source_table", :limit => 45
	  end

	  add_index "forms", ["name"], :name => "idx_name_unique", :unique => true

	  create_table "instruments", :force => true do |t|
	    t.string   "manufacturer",                :limit => 80
	    t.integer  "submission_id"
	    t.string   "model",                       :limit => 50
	    t.string   "instrument_name",             :limit => 80
	    t.string   "analyzer_description",        :limit => 40
	    t.string   "analyzer_mode",               :limit => 30
	    t.text     "analyzer_long_description"
	    t.string   "instr_thruput_funct",         :limit => 20
	    t.text     "instr_thruput_comment"
	    t.string   "excitation_src_window",       :limit => 130
	    t.string   "raster_frame_rate_unit",      :limit => 2
	    t.string   "raster_frame_rate",           :limit => 20
	    t.text     "detector_descrip"
	    t.string   "emission_angle",              :limit => 10
	    t.string   "incident_angle",              :limit => 10
	    t.string   "src_to_analyzer",             :limit => 10
	    t.string   "specimen_azimuth",            :limit => 10
	    t.string   "acceptance_angle",            :limit => 10
	    t.string   "ion_gun_used_flag",           :limit => 3
	    t.string   "ancillary_ion_gun_mfr",       :limit => 80
	    t.string   "ancillary_ion_gun_model",     :limit => 20
	    t.string   "sputtr_src_species",          :limit => 20
	    t.string   "sputtr_species_charge",       :limit => 16
	    t.string   "sputtr_species_energy",       :limit => 16
	    t.string   "sputtr_src_current_unit",     :limit => 10
	    t.string   "sputtr_src_current",          :limit => 16
	    t.string   "sputtr_current_measure_meth", :limit => 14
	    t.string   "sputtr_src_beam_diam",        :limit => 16
	    t.string   "ion_gun_raster_flag",         :limit => 3
	    t.string   "sputtr_src_width_X",          :limit => 16
	    t.string   "sputtr_src_width_Y",          :limit => 16
	    t.string   "sputtr_src_incident_ang",     :limit => 10
	    t.string   "sputtr_src_polar_ang",        :limit => 10
	    t.string   "sputtr_src_azimuth_ang",      :limit => 10
	    t.string   "number_detect_elements",      :limit => 80
	    t.datetime "updated_on"
	    t.text     "angular_geom_comment"
	    t.text     "sputtering_comment"
	  end

	  create_table "keywords", :force => true do |t|
	    t.integer  "submission_id"
	    t.integer  "seqnum"
	    t.string   "keyword",       :limit => 128
	    t.datetime "updated_on"
	  end

	  create_table "lookups", :force => true do |t|
	    t.string   "table_name",  :limit => 40
	    t.string   "field_name",  :limit => 40
	    t.string   "field_value", :limit => 40
	    t.integer  "active",      :limit => 1
	    t.string   "remarks"
	    t.datetime "updated_on"
	  end

	  add_index "lookups", ["table_name", "field_name", "field_value"], :name => "idx_lookup01", :unique => true

	  create_table "major_elements", :force => true do |t|
	    t.integer "submission_id"
	    t.integer "seqnum"
	    t.string  "major_element_name", :limit => 40
	  end

	  create_table "minor_elements", :force => true do |t|
	    t.integer "submission_id",                    :null => false
	    t.integer "seqnum"
	    t.string  "minor_element_name", :limit => 40
	  end

	  create_table "named_peaks", :force => true do |t|
	    t.integer  "spectrum_id"
	    t.integer  "seqnum"
	    t.string   "species_label",    :limit => 30
	    t.string   "transition_label", :limit => 30
	    t.datetime "updated_on"
	  end

	  create_table "paramsets", :force => true do |t|
	    t.integer  "instrument_id"
	    t.integer  "seqnum"
	    t.string   "excite_src_char_energy",      :limit => 20
	    t.string   "excit_src_strength_unit",     :limit => 20
	    t.string   "excit_src_strength",          :limit => 20
	    t.string   "excit_src_beamXdiam",         :limit => 20
	    t.string   "excit_src_beamYdiam",         :limit => 20
	    t.string   "excit_src_raster_flag",       :limit => 5
	    t.string   "excit_src_width_x",           :limit => 20
	    t.string   "excit_src_width_y",           :limit => 20
	    t.string   "pass_energy_retard_rat_unit", :limit => 5
	    t.string   "pass_energy_retard_rat",      :limit => 20
	    t.string   "analyzer_resolution_unit",    :limit => 40
	    t.string   "analyzer_resolution",         :limit => 20
	    t.string   "analyzer_constant_width",     :limit => 5
	    t.string   "analyzer_width_x",            :limit => 20
	    t.string   "analyzer_width_y",            :limit => 20
	    t.string   "analyzer_width_energy",       :limit => 20
	    t.string   "ang_accept_constant_width",   :limit => 5
	    t.string   "ang_x_accept_width",          :limit => 20
	    t.string   "ang_y_accept_width",          :limit => 20
	    t.string   "ang_accept_energy",           :limit => 20
	    t.integer  "authors_param_set_num"
	    t.datetime "updated_on"
	    t.string   "raster_frame_rate",           :limit => 20
	    t.string   "excitation_source_label",     :limit => 20
	    t.text     "excitation_source"
	    t.string   "technique",                   :limit => 20
	    t.text     "technique_other"
	  end

	  create_table "permissions", :id => false, :force => true do |t|
	    t.string "controller", :limit => 64
	    t.string "action",     :limit => 64
	    t.string "role",       :limit => 20
	    t.string "permission", :limit => 12
	  end

	  create_table "planes", :force => true do |t|
	    t.string   "builder"
	    t.string   "model_num"
	    t.string   "call_sign"
	    t.integer  "seat_count"
	    t.decimal  "cruise_speed", :precision => 10, :scale => 0
	    t.datetime "created_at"
	    t.datetime "updated_at"
	  end

	  create_table "reference_authors", :force => true do |t|
	    t.integer  "submission_reference_id"
	    t.integer  "seqnum"
	    t.string   "fname",                   :limit => 20
	    t.string   "lname",                   :limit => 20
	    t.string   "mname",                   :limit => 20
	    t.datetime "updated_on"
	  end

	  create_table "sess_users", :id => false, :force => true do |t|
	    t.string   "session_id", :limit => 32, :default => "", :null => false
	    t.integer  "user_id"
	    t.datetime "created_on"
	    t.datetime "updated_on"
	  end

	  create_table "sessions", :force => true do |t|
	    t.string   "session_id"
	    t.text     "data"
	    t.datetime "updated_at"
	  end

	  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
	  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

	  create_table "specimens", :force => true do |t|
	    t.integer  "submission_id"
	    t.integer  "seqnum"
	    t.string   "host",                      :limit => 225
	    t.string   "cas_registry_number",       :limit => 30
	    t.string   "material_designating_org",  :limit => 80
	    t.string   "material_designation",      :limit => 30
	    t.text     "host_composition"
	    t.string   "chemical_name",             :limit => 225
	    t.string   "chemical_form"
	    t.string   "manufacturer",              :limit => 225
	    t.string   "lot_num",                   :limit => 30
	    t.string   "homogeneity",               :limit => 40
	    t.string   "crystallinity",             :limit => 40
	    t.string   "phase",                     :limit => 40
	    t.string   "material_family",           :limit => 40
	    t.string   "electrical_characteristic", :limit => 40
	    t.string   "special_material_classes",  :limit => 40
	    t.string   "specimen_temp_unit",        :limit => 10
	    t.string   "specimen_temp_value",       :limit => 8
	    t.string   "max_chamber_press",         :limit => 15
	    t.datetime "updated_on"
	    t.text     "chem_struct_formula"
	    t.text     "history_significance"
	    t.text     "as_received_cond"
	    t.text     "analyzed_region"
	    t.text     "exsitu_preparation"
	    t.text     "insitu_preparation"
	    t.text     "pre_anal_beam_exp"
	    t.text     "charge_control_cond"
	    t.integer  "accession_num"
	    t.string   "include_in_journal",        :limit => 3
	    t.text     "journal_description"
	  end

	  create_table "spectra", :force => true do |t|
	    t.integer  "paramset_id"
	    t.integer  "submission_id"
	    t.integer  "specimen_id"
	    t.integer  "seqnum"
	    t.string   "signal_mode",                   :limit => 30
	    t.string   "signal_collect_time_unit",      :limit => 5
	    t.string   "signal_collect_time_value",     :limit => 20
	    t.string   "seconds_per_scan",              :limit => 20
	    t.integer  "number_of_scans"
	    t.string   "signal_time_correct_unit",      :limit => 5
	    t.string   "signal_time_correct",           :limit => 10
	    t.string   "data_acquisition_time_un",      :limit => 5
	    t.string   "data_acquisition_time_val",     :limit => 20
	    t.integer  "equiv_simultaneous_chnnls"
	    t.string   "spectrum_modul_method",         :limit => 20
	    t.string   "modulation_ampl_unit",          :limit => 5
	    t.string   "modulation_ampl_val",           :limit => 20
	    t.string   "modulation_freq",               :limit => 20
	    t.string   "demod_time_const",              :limit => 20
	    t.string   "specimen_calibration",          :limit => 20
	    t.string   "region_type",                   :limit => 20
	    t.string   "sss_publication_flag",          :limit => 20
	    t.string   "suggested_pub_status",          :limit => 20
	    t.string   "data_filename",                 :limit => 32
	    t.datetime "created_on"
	    t.string   "abscissa_label",                :limit => 60
	    t.string   "abscissa_unit",                 :limit => 5
	    t.string   "abscissa_start",                :limit => 20
	    t.string   "abscissa_increment",            :limit => 20
	    t.integer  "number_of_data_channels"
	    t.string   "ordinate_label",                :limit => 20
	    t.string   "ordinate_units",                :limit => 20
	    t.integer  "authors_param_set_num"
	    t.datetime "updated_on"
	    t.text     "expermnt_spec_region"
	    t.text     "angular_accept_width"
	    t.text     "signal_intensity_correction"
	    t.string   "total_signal_accum_time",       :limit => 20
	    t.string   "total_elapsed_time",            :limit => 20
	    t.string   "effective_detector_width",      :limit => 20
	    t.string   "part_j_description",            :limit => 50
	    t.integer  "author_spectrum_no"
	    t.integer  "accession_spectrum_num"
	    t.integer  "exclude_from_proof",            :limit => 1
	    t.date     "spectrum_date"
	    t.binary   "data_file"
	    t.binary   "figure_img_file"
	    t.string   "spectrum_date_text",            :limit => 20
	    t.text     "data_files_comment"
	    t.string   "figure_img_filename",           :limit => 45
	    t.text     "spectrum_comment"
	    t.text     "signal_intensity_correct_desc"
	  end

	  create_table "spectral_feat_tbl_units", :force => true do |t|
	    t.integer "submission_id",                    :null => false
	    t.string  "peak_ampl_method",   :limit => 20
	    t.string  "peak_ampl_unit",     :limit => 40
	    t.string  "concentration_unit", :limit => 20
	    t.text    "calib_tbl_comment"
	    t.text    "feat_tbl_comment"
	  end

	  create_table "spectral_features", :force => true do |t|
	    t.integer  "seqnum"
	    t.integer  "spectrum_id"
	    t.string   "element",                      :limit => 32
	    t.string   "spectral_type",                :limit => 20
	    t.string   "peak_transition",              :limit => 32
	    t.string   "peak_energy",                  :limit => 32
	    t.string   "peak_energy_precis",           :limit => 32
	    t.string   "peak_fwhm",                    :limit => 32
	    t.string   "peak_fwhm_precis",             :limit => 32
	    t.string   "peak_amplitude",               :limit => 32
	    t.string   "peak_ampli_precis",            :limit => 32
	    t.string   "peak_sensitivity",             :limit => 32
	    t.string   "peak_sensit_precis",           :limit => 32
	    t.string   "concentration",                :limit => 32
	    t.string   "concentration_precis",         :limit => 32
	    t.string   "peak_assignment"
	    t.text     "peak_assignment_comment"
	    t.integer  "spectral_region_num"
	    t.text     "lineitem_footnotes"
	    t.string   "lineitem_footnote_marker",     :limit => 32
	    t.datetime "updated_on"
	    t.integer  "named_accession_num"
	    t.integer  "named_accession_spectrum_num"
	    t.integer  "specimen_id"
	    t.integer  "submission_id"
	  end

	  create_table "submiss_instruments", :force => true do |t|
	    t.integer "fk_submiss_id"
	    t.integer "fk_instrument_id"
	    t.integer "seqnum"
	  end

	  create_table "submiss_users", :id => false, :force => true do |t|
	    t.integer  "submission_id",              :default => 0, :null => false
	    t.integer  "user_id",                    :default => 0, :null => false
	    t.string   "submiss_admin", :limit => 1
	    t.datetime "created_on"
	  end

	  create_table "submission_references", :force => true do |t|
	    t.integer  "submission_id"
	    t.integer  "seqnum"
	    t.string   "pub_type",        :limit => 18
	    t.string   "title",           :limit => 128
	    t.string   "volume",          :limit => 10
	    t.string   "year_published",  :limit => 9
	    t.string   "edition",         :limit => 30
	    t.string   "publisher",       :limit => 50
	    t.string   "publisher_city",  :limit => 40
	    t.string   "editors",         :limit => 128
	    t.string   "pages",           :limit => 30
	    t.text     "remarks"
	    t.text     "other_reference"
	    t.datetime "updated_on"
	    t.string   "chapter"
	    t.string   "issue",           :limit => 32
	  end

	  create_table "submissions", :force => true do |t|
	    t.string   "category",                :limit => 40
	    t.integer  "specimen_spectra_unpubl"
	    t.string   "spectral_category",       :limit => 20
	    t.integer  "specimen_spectra_publ"
	    t.datetime "updated_on"
	    t.integer  "update_user"
	    t.integer  "calib_spectra_publ"
	    t.datetime "update_source"
	    t.string   "pub_auger_deriv",         :limit => 20
	    t.text     "title"
	    t.text     "introduction"
	    t.text     "abstract"
	    t.text     "acknowldegements"
	    t.text     "general_notes"
	    t.text     "data_center_notes"
	    t.integer  "created_by"
	    t.datetime "created_on"
	    t.string   "short_title"
	    t.string   "wecf_version",            :limit => 20
	    t.text     "pub_notes_for_editors"
	    t.string   "digital_data_format",     :limit => 80
	    t.string   "sugg_reviewer_1",         :limit => 128
	    t.string   "sugg_reviewer_2",         :limit => 128
	    t.string   "sugg_reviewer_3",         :limit => 128
	    t.text     "comments_on_wecf"
	    t.string   "sss_ms_num",              :limit => 20
	    t.string   "submiss_status",          :limit => 40
	    t.datetime "submiss_status_date"
	    t.integer  "parent_id"
	    t.integer  "revision_num"
	    t.datetime "delete_flag"
	  end

	  create_table "sysmenus", :force => true do |t|
	    t.integer "parent_id"
	    t.string  "name",           :limit => 80
	    t.integer "children_count"
	    t.string  "menu_name",      :limit => 20
	    t.text    "get_child_sql"
	    t.string  "target_url",     :limit => 80
	    t.integer "owner_id"
	  end

	  create_table "teams", :force => true do |t|
	    t.string   "name"
	    t.string   "city"
	    t.integer  "position"
	    t.datetime "created_at"
	    t.datetime "updated_at"
	  end

	  create_table "users", :force => true do |t|
	    t.string   "login",                     :limit => 40
	    t.string   "email",                     :limit => 80
	    t.string   "crypted_password",          :limit => 80
	    t.string   "salt",                      :limit => 80
	    t.datetime "created_at"
	    t.datetime "updated_at"
	    t.string   "remember_token",            :limit => 1
	    t.datetime "remember_token_expires_at"
	    t.string   "role",                      :limit => 20
	    t.string   "first_name",                :limit => 30
	    t.string   "last_name",                 :limit => 30
	    t.string   "activation_code",           :limit => 40
	    t.datetime "activated_at"
	    t.string   "institute_name",            :limit => 80
	    t.string   "address1",                  :limit => 40
	    t.string   "address2",                  :limit => 40
	    t.string   "city",                      :limit => 40
	    t.string   "state",                     :limit => 20
	    t.string   "postal_code",               :limit => 20
	    t.string   "country",                   :limit => 20
	    t.string   "phone",                     :limit => 20
	    t.string   "fax",                       :limit => 20
	    t.string   "password_reset_code",       :limit => 45
	    t.string   "show_splash",               :limit => 1
	  end

	  add_index "users", ["email"], :name => "idx_email", :unique => true
  end

  def down
  end
end
