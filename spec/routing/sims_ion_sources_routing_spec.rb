require "spec_helper"

describe SimsIonSourcesController do
  describe "routing" do

    it "routes to #index" do
      get("/sims_ion_sources").should route_to("sims_ion_sources#index")
    end

    it "routes to #new" do
      get("/sims_ion_sources/new").should route_to("sims_ion_sources#new")
    end

    it "routes to #show" do
      get("/sims_ion_sources/1").should route_to("sims_ion_sources#show", :id => "1")
    end

    it "routes to #edit" do
      get("/sims_ion_sources/1/edit").should route_to("sims_ion_sources#edit", :id => "1")
    end

    it "routes to #create" do
      post("/sims_ion_sources").should route_to("sims_ion_sources#create")
    end

    it "routes to #update" do
      put("/sims_ion_sources/1").should route_to("sims_ion_sources#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/sims_ion_sources/1").should route_to("sims_ion_sources#destroy", :id => "1")
    end

  end
end
