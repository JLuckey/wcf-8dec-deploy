class MinorElementController < ApplicationController
#  before_filter :log_this

  layout "submission"

  def conditions_for_collection
    @show_nav_bar = true
    ['submission_id = ? ', session[:submiss_id]]
  end

  active_scaffold :minor_element do |config|
    config.list.columns = [:seqnum, :minor_element_name]
  end

  protected

  def before_create_save(record)
    record.submission_id = session[:submiss_id]
  end

end
