require 'spec_helper'

describe "sims_instrument_configurations/show.html.erb" do
  before(:each) do
    @sims_instrument_configuration = assign(:sims_instrument_configuration, stub_model(SimsInstrumentConfiguration,
      :submission_id => 1,
      :seq_num => 1,
      :analyzer_type => "Analyzer Type",
      :spectrometer_manufacturer => "Spectrometer Manufacturer",
      :manufacturer_model_number => "Manufacturer Model Number",
      :experiment_type => "Experiment Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Analyzer Type/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Spectrometer Manufacturer/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Manufacturer Model Number/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Experiment Type/)
  end
end
