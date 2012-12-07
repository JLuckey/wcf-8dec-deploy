require 'spec_helper'

describe "sims_ion_sources/index.html.erb" do
  before(:each) do
    assign(:sims_ion_sources, [
      stub_model(SimsIonSource),
      stub_model(SimsIonSource)
    ])
  end

  it "renders a list of sims_ion_sources" do
    render
  end
end
