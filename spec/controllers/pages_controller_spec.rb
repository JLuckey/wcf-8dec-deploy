require 'spec_helper'

describe PagesController do
  render_views

  describe "GET 'home'" do
    it "should be successful" do
      get 'home'
      response.should be_success
    end

    it "should have the correct title" do
      get 'home'
      response.should have_selector("title", :content => "Home")
    end  

    it "should have a non-blank body" do
      get 'home'
      response.body.should_not =~/<body>\s*<\/body>/  #should not match empty or only-whitespace in body
    end

  end

  describe "GET 'contact'" do
    it "should be successful" do
      get 'contact'
      response.should be_success
    end

    it "should have the correct title" do
      get 'contact'
      response.should have_selector("title", :content => "Contact")
    end  

    it "should have a non-blank body" do
      get 'contact'
      response.body.should_not =~/<body>\s*<\/body>/  #should not match empty or only-whitespace in body
    end
  end

  describe "GET 'about'" do
    it "should be successful" do
      get 'about'
      response.should be_success
    end

    it "should have the correct title" do
      get 'about'
      response.should have_selector("title", :content => "About")
    end  

    it "should have a non-blank body" do
      get 'about'
      response.body.should_not =~/<body>\s*<\/body>/  #should not match empty or only-whitespace in body
    end

  end

end
