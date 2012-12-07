class ReferenceAuthorController < ApplicationController
#  before_filter :log_this

  active_scaffold :reference_author do |config|
#    config.list.columns.exclude :submission_reference
  	config.columns = [:seqnum, :fname, :mname, :lname]
#  	config.list.columns = [:seqnum, :fname, :mname, :lname]
    columns[:seqnum].label = 'Seq#'
		columns[:fname].label  = 'First Name'
		columns[:mname].label  = 'Middle Name'
		columns[:lname].label  = 'Last Name'
  end

	def conditions_for_collection
    ['submission_reference_id = ? ', session[:reference_id]]
  end

	def before_create_save(record)
		record.submission_reference_id = session[:reference_id]
	end

end
