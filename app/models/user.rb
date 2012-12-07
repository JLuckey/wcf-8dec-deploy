require 'digest/sha1'
class User < ActiveRecord::Base
  has_many :submiss_users,  :dependent => :destroy
  has_many :submissions,    :through   => :submiss_users

  before_create :make_activation_code
  before_save   :encrypt_password

  attr_accessor :password			# Virtual attribute for the unencrypted password

#  validates_presence_of     :password,                  # :if => :password_required?

  validates :password,
            :presence     => true,
            :confirmation => true

  def after_save
    puts('User - after_save fired - 1!')
    UserNotifier.deliver_activation(self) 		 if self.recently_activated?
#		UserNotifier.deliver_forgot_password(self) if self.recently_forgot_password?
    UserNotifier.deliver_reset_password(self)  if self.recently_reset_password?
    puts('User - after_save fired - 2!')

  end

# Validation is now handled by subclasses RegularUser & InviteeUser
#  validates_presence_of     :password,                   :if => :password_required?
#  validates_presence_of     :password_confirmation,      :if => :password_required?
#  validates_length_of       :password, :within => 4..40, :if => :password_required?
#  validates_confirmation_of :password,                   :if => :password_required?
#  validates_length_of       :login,    :within => 3..40
#  validates_length_of       :email,    :within => 3..100
#  validates_uniqueness_of   :login, :email, :case_sensitive => false


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
# ???JL disabling this code in favor of the following method - 2/1/2007 16:35
#  def self.authenticate(login, password)
#    u = find_by_login(login) # need to get the salt
#    u && u.authenticated?(password) ? u : nil
#  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    # hide records with a nil activated_at
    u = find(:first, :conditions => "login = '#{login}' and activated_at IS NOT NULL" )
    # u = find(:first, :conditions => ['login = ? and activated_at IS NOT NULL', login])
    u && u.authenticated?(password) ? u : nil
  end  #authenticate


  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
		self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Activates the user in the database.
  def activate
    @activated = true
    return update_attributes(:activated_at => Time.now.utc, :activation_code => nil)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end


	def forgot_password
		puts 'user.rb#forgot_password fired'
    @forgotten_password = true
    self.make_password_reset_code
  end


  def reset_password
    # First update the password_reset_code before setting the
    # reset_password flag to avoid duplicate email notifications.
    update_attributes(:password_reset_code => nil)
    @reset_password = true
  end

  def recently_reset_password?
    @reset_password
  end

  def recently_forgot_password?
    @forgotten_password
  end

  protected
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?

# 4/8/2008 09:09 test/debug code ???JL
#			if new_record?
#        self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
#			else
#				self.sale =
#			end

			self.crypted_password = encrypt(password)
    end

    def password_required?
      crypted_password.blank? || !password.blank?
    end

    # If you're going to use activation, uncomment this too
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end

	  def make_password_reset_code
      self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end



end     # Class User

