class AnalysisMethod < ActiveRecord::Base

  def updated_on
    read_attribute('updated_on').strftime("%x")
  end

end
