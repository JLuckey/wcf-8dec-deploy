class RegularUser < User

  validates_presence_of     :login

	validates_presence_of     :email
	validates_presence_of     :email_confirmation
	validates_confirmation_of :email

	validates_presence_of     :password
  validates_presence_of     :password_confirmation
  validates_confirmation_of :password

  validates_length_of       :password, :within => 4..40
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 7..100

  validates_uniqueness_of   :login, :email, :case_sensitive => false


  def after_create
    UserNotifier.deliver_signup_notification(self)
#    puts 'User - after_create fired!'
  end

end
