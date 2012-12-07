class InviteeUser < User

  validates_presence_of     :first_name, :last_name, :email

#  validates_uniqueness_of   :email, :case_sensitive => false
# 6/19/2007 15:16 also, consider making InviteeUser the parent & regular user the child


# 2/22/2007 08:12 - Mothballed this code in favor of placing this functionality
#                   in the submission_controller.  Is that the right thing ???JL
#										6/19/2007 15:15 - Dave sez put it back here
  def after_create
#    SubmissUser.create(:submission_id => session[:submiss_id], :user_id => self.id, :submiss_admin => 'N')
		self.submiss_users.create(:submission_id => session[:submiss_id], :submiss_admin => 'N')
		UserNotifier.deliver_invitation(self, session[:submiss_id], session[:user_id])
#		             deliver_invitation(@iu, session[:submiss_id], session[:user_id])
    puts('InviteeUser - after_create fired!')
  end

end

