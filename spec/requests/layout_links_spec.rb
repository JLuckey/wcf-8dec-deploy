require 'spec_helper'

describe "LayoutLinks" do
  # describe "GET /layout_links" do
  #   it "works! (now write some real specs)" do
  #     # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
  #     get layout_links_index_path
  #     response.status.should be(200)
  #   end
  # end

  describe "sign in and sign up" do

  	it "should be successful" do 
  		get '/signin'
  		response.should be_successful
  	end

  	it "should have a signin page at '/signin' " do
  		get '/signin'
  		response.should have_selector('title', :content => "Sign in")
  	end


  end
end
