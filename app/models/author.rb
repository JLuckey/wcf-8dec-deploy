class Author < ActiveRecord::Base
  belongs_to :submission

#  validates_presence_of :fname

end
