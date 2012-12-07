require 'spec_helper'

describe "sims_ion_sources/show.html.erb" do
  before(:each) do
    @sims_ion_source = assign(:sims_ion_source, stub_model(SimsIonSource))
  end

  it "renders attributes in <p>" do
    render
  end
end
