class Spectrum < ActiveRecord::Base

  self.table_name = "spectra"
  belongs_to :submission
  # has_many   :exp_variables, :dependent => :destroy
  has_many   :named_peaks

  def uploaded_file=(data_file_field)
    self.data_filename = File.basename(data_file_field.original_filename)
    self.data_file     = data_file_field.read
  end

  def uploaded_img_file=(figure_img_file_field)
    self.figure_img_filename = File.basename(figure_img_file_field.original_filename)
    self.figure_img_file     = figure_img_file_field.read
  end

#  def updated_on
#    read_attribute('updated_on').strftime("%x")
#  end

#  def created_on
#    read_attribute('created_on').strftime("%x")
#  end

end
