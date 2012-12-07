require "spec_helper"

describe SimsInstrumentConfigurationsController do
  describe "routing" do

    it "routes to #index" do
      get("/sims_instrument_configurations").should route_to("sims_instrument_configurations#index")
    end

    it "routes to #new" do
      get("/sims_instrument_configurations/new").should route_to("sims_instrument_configurations#new")
    end

    it "routes to #show" do
      get("/sims_instrument_configurations/1").should route_to("sims_instrument_configurations#show", :id => "1")
    end

    it "routes to #edit" do
      get("/sims_instrument_configurations/1/edit").should route_to("sims_instrument_configurations#edit", :id => "1")
    end

    it "routes to #create" do
      post("/sims_instrument_configurations").should route_to("sims_instrument_configurations#create")
    end

    it "routes to #update" do
      put("/sims_instrument_configurations/1").should route_to("sims_instrument_configurations#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/sims_instrument_configurations/1").should route_to("sims_instrument_configurations#destroy", :id => "1")
    end

  end
end
