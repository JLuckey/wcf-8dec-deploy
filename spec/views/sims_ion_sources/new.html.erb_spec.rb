require 'spec_helper'

describe "sims_ion_sources/new.html.erb" do
  before(:each) do
    assign(:sims_ion_source, stub_model(SimsIonSource).as_new_record)
  end

  it "renders new sims_ion_source form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sims_ion_sources_path, :method => "post" do
    end
  end
end
