class SubmissUser < ActiveRecord::Base
  belongs_to  :submission
  belongs_to  :user

end  # SubmissUser
