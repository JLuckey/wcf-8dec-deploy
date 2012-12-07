require 'spec_helper'

describe "sims_ion_sources/edit.html.erb" do
  before(:each) do
    @sims_ion_source = assign(:sims_ion_source, stub_model(SimsIonSource))
  end

  it "renders the edit sims_ion_source form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sims_ion_sources_path(@sims_ion_source), :method => "post" do
    end
  end
end
