class Submission < ActiveRecord::Base
#  has_and_belongs_to_many :users
  has_many :submiss_users,   :dependent => :destroy
  has_many :users,           :through   => :submiss_users
  has_many :authors,         :dependent => :destroy
  has_many :specimens,       :dependent => :destroy
  has_many :instruments
  has_many :spectra
#  has_many :spectral_feat_tbl_units

	validates_presence_of :title

	def is_locked?
		return self.submiss_status.to_s.downcase == 'submitted' ||
					 self.submiss_status.to_s.downcase == 'dumped' 	 	||
					 self.submiss_status.to_s.downcase == 'exported'  ||
					 self.submiss_status.to_s.downcase == 'accepted'  ||
					 self.submiss_status.to_s.downcase == 'published' ||
					 self.submiss_status.to_s.downcase == 'revised-by-author' ||
					 self.submiss_status.to_s.downcase == 'original'
	end  # is_locked?


end  # Submission
