class AdditionalFile < ActiveRecord::Base

  def uploaded_file=(data_file_field)
    self.additional_file_name = File.basename(data_file_field.original_filename)
    self.additional_data_file = data_file_field.read
  end

end
