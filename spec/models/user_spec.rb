require 'spec_helper'

describe User do

  before(:each) do
	  @user_attr = { :login                 => 'gbush', 
                   :email                 => 'gb@wh.gov',
                   :password              => 'foobar',
                   :password_confirmation => 'foobar'
                 }
  end	

  it "should create a new instance given a valid attribute" do
  	# User.create!(:login => "Example User", :email => "user@example.com")
    User.create!(@user_attr)
  end

  it "should require a name" do 
    no_name_user = User.new(:email => 'foo@bar.com')  	
    no_name_user.should_not be_valid
  end

  it "should require an email" do 
    no_email_user = User.new(:login => 'no email user')  	
    no_email_user.should_not be_valid
  end

  it "should reject logins that are too long" do
    long_name = 'a' * 51
    long_name_user = User.new(:login =>long_name, :email => 'foo@bar.com')
    long_name_user.should_not be_valid
  end	

  # valid_emails = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]

  it "should accept valid email addresses" do
    valid_emails = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    valid_emails.each do |address|
      valid_email_user = User.new(@user_attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end	

  it "should reject invalid email addresses" do
  	invalid_emails = %w[user@foo,com user_at_foo.org, example.user@foo.]
    invalid_emails.each do |address|
      invalid_email_user = User.new(@user_attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end	

  it "should reject duplicate email addresses" do
    User.create!(@user_attr)
    user_with_dup_email = User.new(@user_attr)
    user_with_dup_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do 
    upcase_email = @user_attr[:email].upcase
    User.create!(@user_attr.merge(:email => upcase_email))
    user_with_dup_email = User.new(@user_attr)
    user_with_dup_email.should_not be_valid
  end

  
  describe "passwords" do

    before(:each) do
      @test_user = User.new(@user_attr)
    end

    it "should have a password attribute" do
      @test_user.should respond_to('password')
    end

    it "should have a password confirmation attribute" do
      @test_user.should respond_to('password_confirmation')
    end
      
   end   # describe "passwords" block


   describe "password validations" do

     it "should require a password" do
       User.new(@user_attr.merge(:password => '', :password_confirmation => '')).should_not be_valid
     end
 
     it "should require a matching password confirmation" do
       User.new(@user_attr.merge( :password_confirmation => 'invalid')).should_not be_valid
     end

     it "should reject short passwords" do
       short = 'a' * 5
       myHash = @user_attr.merge(:password => short, :password_confirmation => short)
       User.new(myHash).should_not be_valid
     end

     it "should reject long passwords" do
       long = 'a' * 41
       myHash = @user_attr.merge(:password => long, :password_confirmation => long)
       User.new(myHash).should_not be_valid
     end
   
   end  # describe "password validations" block

   
   describe "password encryption" do
     before(:each) do
       @test_user = User.create!(@user_attr)  # actually creates a user record in the database
     end                                      #  as opposed to just instatiating a User object

     it "should have an encrypted password attribute"  do
       @test_user.should respond_to('crypted_password')
     end

     it "should have a salt attribute"  do
       @test_user.should respond_to('salt')
     end

     it "should set crypted password attribute" do       
       @test_user.crypted_password.should_not be_blank
     end
       
     describe "has passowrd? method"  do
       it "should exist" do
         @test_user.should respond_to(:has_password?)
       end
       
       it "should return true if passwords match" do
         @test_user.has_password?(@user_attr[:password]).should be_true
       end

       it "should return false if passwords do not match" do
         @test_user.has_password?(@user_attr["invalid"]).should be_false
       end
     end
    
     describe "authenticate method" do
       it "should exist" do
         User.should respond_to(:authenticate)
       end

       it "should return nil on email/password mismatch" do
         User.authenticate(@user_attr[:email], "wrongpass").should be_nil
       end

       it "should return nil for an email with no user" do
         User.authenticate("bar@foo.com", @user_attr[:password]).should be_nil
       end

       it "should return the user on password/email match" do
         User.authenticate(@user_attr[:email], @user_attr[:password]).should == @test_user
       end

     end  # describe "authenticate method" block

   end  # describe "password encryption" block

end  # of file
