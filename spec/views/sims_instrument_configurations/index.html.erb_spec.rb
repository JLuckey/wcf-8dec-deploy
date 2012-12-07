require 'spec_helper'

describe "sims_instrument_configurations/index.html.erb" do
  before(:each) do
    assign(:sims_instrument_configurations, [
      stub_model(SimsInstrumentConfiguration,
        :submission_id => 1,
        :seq_num => 1,
        :analyzer_type => "Analyzer Type",
        :spectrometer_manufacturer => "Spectrometer Manufacturer",
        :manufacturer_model_number => "Manufacturer Model Number",
        :experiment_type => "Experiment Type"
      ),
      stub_model(SimsInstrumentConfiguration,
        :submission_id => 1,
        :seq_num => 1,
        :analyzer_type => "Analyzer Type",
        :spectrometer_manufacturer => "Spectrometer Manufacturer",
        :manufacturer_model_number => "Manufacturer Model Number",
        :experiment_type => "Experiment Type"
      )
    ])
  end

  it "renders a list of sims_instrument_configurations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Analyzer Type".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Spectrometer Manufacturer".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Manufacturer Model Number".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Experiment Type".to_s, :count => 2
  end
end
