class NamedPeakController < ApplicationController

#  before_filter :log_this

  active_scaffold :named_peak do |config|
    config.label = 'Species/Transitions for this Spectrum'
    config.list.columns = [:seqnum, :species_label, :transition_label]
#    config.list.columns.exclude :spectras
#    columns[:seqnum].label = 'Seq#'
  end

  def conditions_for_collection
    ['spectrum_id = ? ', session[:spectrum_id]]
  end

  def before_create_save(record)
    record.spectrum_id = session[:spectrum_id]
  end

end
