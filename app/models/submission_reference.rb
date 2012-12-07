class SubmissionReference < ActiveRecord::Base
	has_many :reference_authors,  :dependent => :destroy

end
