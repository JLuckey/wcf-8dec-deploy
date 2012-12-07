require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'show'" do

    before(:each) do
      @user = Factory(:user)
    end

    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find the correct user" do
      get :show, :id => @user
      assigns(:user).should == @user  
    end

    it "should have user's name in title" do
      get :show, :id => @user
      response.should have_selector('title', :content => @user.last_name)  
    end

    it "should have user's last name in a heading" do
      get :show, :id => @user
      response.should have_selector('h1', :content => @user.last_name)  
    end



  end  # describe "GET 'show'"


  describe "GET 'new'" do

    it "should be successful" do
      get 'new'
      response.should be_success
    end


    
  end   # describe "GET 'new'"


  describe "POST 'CREATE'" do
    describe "failure" do

      before(:each) do
        @attr = { :name => '', :email => '', :password => '', :password_confirmation => '' }  
      end

      it "should have correct title" do
        post :create, :user => @attr
        response.should have_selector('title', :content => 'Sign up' )
      end

      it "should render the new page" do
        post :create, :user => @attr
        response.should render_template('new')
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)  
      end

    end

    describe "success" do
      before(:each) do
        @attr = { :login => 'New User',  :email => 'user@example.com', 
                  :password => 'foobar', :password_confirmation => 'foobar' }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the user show page" do
        post :create, :user => @attr        
        response.should redirect_to(user_path(assigns(:user)))  
      end


    end
  end

end
